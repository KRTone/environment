resource "random_password" "runner_token" {
  length  = 48
  special = false
}

resource "docker_volume" "gitea_data" {
  name = "gitea-data"
}

resource "docker_image" "gitea" {
  name = var.gitea_image
}

locals {
  # Job-контейнеры runner не видят localhost хоста — actions клонируются по внутреннему имени gitea в Docker-сети.
  gitea_actions_url = var.gitea_actions_url != "" ? var.gitea_actions_url : "http://gitea:${var.gitea_port}"

  gitea_env = [
    "USER_UID=1000",
    "USER_GID=1000",
    "GITEA__security__INSTALL_LOCK=true",
    "GITEA__database__DB_TYPE=sqlite3",
    "GITEA__database__PATH=/data/gitea/gitea.db",
    "GITEA__server__DOMAIN=localhost",
    "GITEA__server__ROOT_URL=${var.gitea_root_url}",
    "GITEA__server__SSH_DOMAIN=localhost",
    "GITEA__server__SSH_PORT=${var.gitea_ssh_port}",
    "GITEA__server__HTTP_PORT=${var.gitea_port}",
    "GITEA__actions__ENABLED=true",
    "GITEA__actions__DEFAULT_ACTIONS_URL=${local.gitea_actions_url}",
    "GITEA_RUNNER_REGISTRATION_TOKEN=${random_password.runner_token.result}",
  ]
}

resource "docker_container" "gitea" {
  name  = "gitea"
  image = docker_image.gitea.image_id

  restart = "unless-stopped"

  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = var.gitea_port
    external = var.gitea_port
  }

  ports {
    internal = 22
    external = var.gitea_ssh_port
  }

  env = local.gitea_env

  volumes {
    volume_name    = docker_volume.gitea_data.name
    container_path = "/data"
  }

  healthcheck {
    test         = ["CMD", "wget", "-q", "--spider", "http://localhost:${var.gitea_port}/api/healthz"]
    interval     = "10s"
    timeout      = "5s"
    retries      = 12
    start_period = "30s"
  }
}

resource "null_resource" "gitea_admin" {
  depends_on = [docker_container.gitea]

  triggers = {
    container_id   = docker_container.gitea.id
    admin_user     = var.admin_username
    admin_email    = var.admin_email
    admin_password = var.admin_password
  }

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    environment = {
      GITEA_ADMIN_USERNAME = var.admin_username
      GITEA_ADMIN_PASSWORD = var.admin_password
      GITEA_ADMIN_EMAIL    = var.admin_email
    }
    command = <<-EOT
      $ErrorActionPreference = "Continue"

      $healthy = $false
      for ($i = 0; $i -lt 60; $i++) {
        $health = docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}unknown{{end}}' gitea 2>$null
        if ($health -eq "healthy") {
          $healthy = $true
          break
        }
        Start-Sleep -Seconds 2
      }

      if (-not $healthy) {
        Write-Error "Gitea container is not healthy after waiting"
        exit 1
      }

      $output = docker exec -u git gitea gitea admin user create `
        --admin `
        --username $env:GITEA_ADMIN_USERNAME `
        --password $env:GITEA_ADMIN_PASSWORD `
        --email $env:GITEA_ADMIN_EMAIL `
        --must-change-password=false 2>&1 | Out-String

      if ($LASTEXITCODE -eq 0) {
        exit 0
      }

      if ($output -match "already exists|user already") {
        exit 0
      }

      Write-Error $output
      exit 1
    EOT
  }
}

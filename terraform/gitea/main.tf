resource "docker_volume" "gitea_data" {
  name = "gitea-data"
}

resource "docker_image" "gitea" {
  name = var.gitea_image
}

locals {
  gitea_actions_url = var.gitea_actions_url != "" ? var.gitea_actions_url : "http://gitea:${var.gitea_port}"

  gitea_env = [
    "USER_UID=1000",
    "USER_GID=1000",
    "GITEA__database__DB_TYPE=sqlite3",
    "GITEA__database__PATH=/data/gitea/gitea.db",
    "GITEA__server__DOMAIN=gitea",
    "GITEA__server__ROOT_URL=${var.gitea_root_url}",
    "GITEA__server__SSH_DOMAIN=gitea",
    "GITEA__server__SSH_PORT=${var.gitea_ssh_port}",
    "GITEA__server__HTTP_PORT=${var.gitea_port}",
    "GITEA__actions__ENABLED=true",
    "GITEA__actions__DEFAULT_ACTIONS_URL=${local.gitea_actions_url}",
    "GITEA_RUNNER_REGISTRATION_TOKEN=${var.runner_registration_token}",
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
    test         = ["CMD", "wget", "-q", "--spider", "http://gitea:${var.gitea_port}/api/healthz"]
    interval     = "10s"
    timeout      = "5s"
    retries      = 12
    start_period = "30s"
  }
}

resource "time_sleep" "wait_for_gitea" {
  depends_on      = [docker_container.gitea]
  create_duration = "20s"
}

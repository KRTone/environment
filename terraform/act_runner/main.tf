resource "local_file" "runner_config" {
  content = templatefile("${path.module}/config.yaml.tpl", {
    network_name = var.network_name
  })
  filename = "${path.module}/.generated/config.yaml"
}

resource "docker_volume" "runner_data" {
  name = "gitea-runner-data"
}

resource "docker_image" "act_runner" {
  name         = var.act_runner_image
  keep_locally = true

  build {
    context    = path.module
    dockerfile = "Dockerfile"
    tag        = [var.act_runner_image]
  }

  triggers = {
    dockerfile = filesha256("${path.module}/Dockerfile")
  }
}

locals {
  gitea_instance_url = "http://${var.gitea_container_hostname}:${var.gitea_port}"

  runner_env = [
    "CONFIG_FILE=/etc/act_runner/config.yaml",
    "GITEA_INSTANCE_URL=${local.gitea_instance_url}",
    "GITEA_RUNNER_REGISTRATION_TOKEN=${var.runner_registration_token}",
    "GITEA_RUNNER_NAME=${var.runner_name}",
    "GITEA_RUNNER_LABELS=${var.runner_labels}",
  ]
}

resource "docker_container" "act_runner" {
  name  = var.container_name
  image = docker_image.act_runner.image_id

  restart = "unless-stopped"

  depends_on = [local_file.runner_config]

  networks_advanced {
    name = var.network_name
  }

  env = local.runner_env

  volumes {
    host_path      = abspath(local_file.runner_config.filename)
    container_path = "/etc/act_runner/config.yaml"
    read_only      = true
  }

  volumes {
    volume_name    = docker_volume.runner_data.name
    container_path = "/data"
  }

  volumes {
    host_path      = var.docker_socket_path
    container_path = "/var/run/docker.sock"
  }
}

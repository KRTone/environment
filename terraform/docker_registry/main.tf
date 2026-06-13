resource "docker_image" "registry" {
  name = var.registry_image
}

resource "docker_container" "registry" {
  name  = var.container_name
  image = docker_image.registry.image_id

  restart = "unless-stopped"

  ports {
    internal = var.registry_port
    external = var.registry_host_port
  }

  networks_advanced {
    name = var.network_name
  }
}

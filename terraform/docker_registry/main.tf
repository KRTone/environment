resource "docker_image" "registry" {
  name = var.registry_image
}

resource "docker_container" "registry" {
  name  = var.container_name
  image = docker_image.registry.image_id

  restart = "unless-stopped"

  networks_advanced {
    name = var.network_name
  }
}

resource "docker_image" "registry" {
  count = var.create_dotnet_repo ? 1 : 0
  name  = "registry:2"
}

resource "docker_container" "registry" {
  count = var.create_dotnet_repo ? 1 : 0

  name  = "environment-registry"
  image = docker_image.registry[0].image_id

  restart = "unless-stopped"

  ports {
    internal = 5000
    external = var.k8s_registry_node_port
  }

  networks_advanced {
    name = docker_network.gitea.name
  }
}

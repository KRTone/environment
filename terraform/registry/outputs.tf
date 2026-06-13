output "container_name" {
  description = "Имя контейнера Docker registry"
  value       = docker_container.registry.name
}

output "registry_port" {
  description = "Порт registry на хосте"
  value       = var.registry_port
}

output "registry_url" {
  description = "URL локального Docker registry для CI (push/pull образов)"
  value       = "localhost:${var.registry_port}"
}

output "network_name" {
  description = "Имя Docker-сети registry"
  value       = var.network_name
}

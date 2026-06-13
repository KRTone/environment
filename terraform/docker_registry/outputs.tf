output "container_name" {
  description = "Имя контейнера Docker registry"
  value       = docker_container.registry.name
}

output "registry_port" {
  description = "Внутренний порт registry в Docker-сети"
  value       = var.registry_port
}

output "registry_address" {
  description = "Адрес registry для push/pull из контейнеров в Docker-сети (host:port)"
  value       = "${var.container_name}:${var.registry_port}"
}

output "registry_url" {
  description = "URL registry в Docker-сети"
  value       = "http://${var.container_name}:${var.registry_port}"
}

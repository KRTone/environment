output "container_name" {
  description = "Имя контейнера Docker registry"
  value       = docker_container.registry.name
}

output "registry_port" {
  description = "Внутренний порт registry в Docker-сети"
  value       = var.registry_port
}

output "registry_address" {
  description = "Адрес registry для pull в Kubernetes (host:port в Docker-сети)"
  value       = "${var.container_name}:${var.registry_port}"
}

output "registry_host_port" {
  description = "Порт registry на хосте"
  value       = var.registry_host_port
}

output "registry_push_address" {
  description = "Адрес registry для docker push из CI (через Docker socket на хосте)"
  value       = "host.docker.internal:${var.registry_host_port}"
}

output "registry_url" {
  description = "URL registry в Docker-сети"
  value       = "http://${var.container_name}:${var.registry_port}"
}

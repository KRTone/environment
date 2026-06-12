output "runner_container_name" {
  description = "Имя контейнера Gitea Actions runner"
  value       = docker_container.act_runner.name
}

output "gitea_instance_url" {
  description = "URL Gitea, к которому подключён runner"
  value       = local.gitea_instance_url
}

output "runner_name" {
  description = "Имя runner в Gitea"
  value       = var.runner_name
}

output "network_name" {
  description = "Имя Docker-сети runner"
  value       = var.network_name
}

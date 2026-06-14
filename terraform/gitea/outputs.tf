output "gitea_url" {
  description = "URL веб-интерфейса Gitea"
  value       = var.gitea_root_url
}

output "gitea_ssh_port" {
  description = "SSH-порт для git clone по SSH"
  value       = var.gitea_ssh_port
}

output "admin_username" {
  description = "Логин администратора"
  value       = var.admin_username
}

output "admin_email" {
  description = "Email администратора"
  value       = var.admin_email
}

output "gitea_container_name" {
  description = "Имя контейнера Gitea"
  value       = docker_container.gitea.name
}

output "network_name" {
  description = "Имя Docker-сети Gitea"
  value       = var.network_name
}

output "runner_gitea_url" {
  description = "URL Gitea для act_runner в той же Docker-сети"
  value       = "http://${docker_container.gitea.name}:${var.gitea_port}"
}

output "runner_registration_token" {
  description = "Токен регистрации Gitea Actions runner"
  value       = var.runner_registration_token
  sensitive   = true
}

output "network_name" {
  description = "Имя Docker-сети"
  value       = docker_network.gitea.name
}

output "gitea_url" {
  description = "URL веб-интерфейса Gitea"
  value       = module.gitea.gitea_url
}

output "gitea_ssh_port" {
  description = "SSH-порт для git clone по SSH"
  value       = module.gitea.gitea_ssh_port
}

output "admin_username" {
  description = "Логин администратора"
  value       = module.gitea.admin_username
}

output "admin_email" {
  description = "Email администратора"
  value       = module.gitea.admin_email
}

output "gitea_container_name" {
  description = "Имя контейнера Gitea"
  value       = module.gitea.gitea_container_name
}

output "runner_container_name" {
  description = "Имя контейнера Gitea Actions runner"
  value       = module.act_runner.runner_container_name
}

output "runner_name" {
  description = "Имя runner в Gitea"
  value       = module.act_runner.runner_name
}

output "runner_registration_token" {
  description = "Токен регистрации Gitea Actions runner"
  value       = module.gitea.runner_registration_token
  sensitive   = true
}

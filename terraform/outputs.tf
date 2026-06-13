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

output "registry_url" {
  description = "URL Docker registry в сети gitea-network"
  value       = module.docker_registry.registry_url
}

output "registry_address" {
  description = "Адрес registry для образов в CI и Kubernetes (host:port)"
  value       = module.docker_registry.registry_address
}

output "registry_container_name" {
  description = "Имя контейнера Docker registry"
  value       = module.docker_registry.container_name
}

output "k8s_cluster_name" {
  description = "Имя k3d-кластера"
  value       = var.create_k8s_cluster ? module.k8s_cluster[0].cluster_name : null
}

output "k8s_cluster_context" {
  description = "Имя контекста kubectl для CI (k3d-<cluster_name>)"
  value       = var.create_k8s_cluster ? module.k8s_cluster[0].cluster_context : null
}

output "k8s_api_server" {
  description = "Адрес API Kubernetes в Docker-сети"
  value       = var.create_k8s_cluster ? module.k8s_cluster[0].api_server : null
}

output "kubeconfig_path" {
  description = "Путь к kubeconfig для kubectl с хоста"
  value       = local.kubeconfig_host_path
}

output "kubeconfig_runner_path" {
  description = "Путь к kubeconfig для act_runner и CI (смонтирован в /kube/config)"
  value       = local.kubeconfig_runner_path
}

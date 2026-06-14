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
  description = "Адрес registry для pull в Kubernetes (docker-registry:5000 в gitea-network)"
  value       = module.docker_registry.registry_address
}

output "registry_host_port" {
  description = "Порт registry на хосте"
  value       = module.docker_registry.registry_host_port
}

output "registry_push_address" {
  description = "Адрес registry для docker push из CI"
  value       = module.docker_registry.registry_push_address
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
  description = "Имя контекста kubectl (k3d-<cluster_name>)"
  value       = var.create_k8s_cluster ? module.k8s_cluster[0].cluster_context : null
}

output "kubeconfig" {
  description = "Kubeconfig k3d-кластера (строка, для kubectl --kubeconfig или KUBECONFIG)"
  value       = var.create_k8s_cluster ? module.k8s_cluster[0].kubeconfig : null
  sensitive   = true
}

output "argocd_ui_url" {
  description = "URL UI ArgoCD (NodePort k3d)"
  value       = var.create_k8s_cluster && var.install_argocd ? module.argocd[0].ui_url : null
}

output "argocd_app_namespace" {
  description = "Namespace приложений для ручного GitOps"
  value       = var.create_k8s_cluster && var.install_argocd ? module.argocd[0].app_namespace : null
}

output "argocd_admin_password" {
  description = "Пароль admin ArgoCD (статический, см. argocd-values.yaml)"
  value       = var.create_k8s_cluster && var.install_argocd ? var.argocd_admin_password : null
  sensitive   = true
}

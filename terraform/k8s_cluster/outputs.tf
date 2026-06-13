output "cluster_name" {
  description = "Имя k3d-кластера"
  value       = var.cluster_name
}

output "cluster_context" {
  description = "Имя контекста kubectl (k3d-<cluster_name>)"
  value       = "k3d-${var.cluster_name}"
}

output "api_server" {
  description = "Адрес API-сервера Kubernetes в Docker-сети"
  value       = "k3d-${var.cluster_name}-server-0:6443"
}

output "kubeconfig_path" {
  description = "Путь к kubeconfig для kubectl с хоста"
  value       = var.kubeconfig_path
}

output "kubeconfig_runner_path" {
  description = "Путь к kubeconfig для act_runner и CI"
  value       = "${var.kubeconfig_path}-runner"
}

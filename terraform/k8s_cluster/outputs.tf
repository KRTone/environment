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

output "host" {
  description = "URL Kubernetes API для провайдеров"
  value       = k3d_cluster.this.host
}

output "client_certificate" {
  description = "Client certificate (base64) для провайдеров Kubernetes"
  value       = k3d_cluster.this.client_certificate
}

output "client_key" {
  description = "Client key (base64) для провайдеров Kubernetes"
  value       = k3d_cluster.this.client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate (base64) для провайдеров Kubernetes"
  value       = k3d_cluster.this.cluster_ca_certificate
}

output "kubeconfig" {
  description = "Kubeconfig кластера (строка)"
  value       = k3d_cluster.this.kubeconfig
  sensitive   = true
}

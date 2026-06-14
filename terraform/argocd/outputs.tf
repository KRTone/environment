output "namespace" {
  description = "Namespace ArgoCD"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "app_namespace" {
  description = "Namespace приложений"
  value       = kubernetes_namespace.apps.metadata[0].name
}

output "ui_node_port" {
  description = "NodePort HTTP для UI ArgoCD"
  value       = var.ui_node_port
}

output "ui_url" {
  description = "URL ArgoCD UI с хоста (NodePort k3d)"
  value       = "http://127.0.0.1:${var.ui_node_port}"
}

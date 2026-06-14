variable "app_namespace" {
  description = "Namespace приложений (репозитории и Application создаются вручную)"
  type        = string
  default     = "apps"
}

variable "helm_chart_version" {
  description = "Версия Helm chart argo-cd"
  type        = string
  default     = "7.7.16"
}

variable "ui_node_port" {
  description = "NodePort HTTP для UI ArgoCD"
  type        = number
  default     = 30090
}

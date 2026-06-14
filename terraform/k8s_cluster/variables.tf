variable "cluster_name" {
  description = "Имя k3d-кластера"
  type        = string
}

variable "network_name" {
  description = "Docker-сеть, к которой подключается k3d"
  type        = string
}

variable "registry_address" {
  description = "Адрес Docker registry в той же сети (host:port)"
  type        = string
}

variable "api_host_port" {
  description = "Порт Kubernetes API на хосте"
  type        = number
}

variable "argocd_ui_node_port" {
  description = "NodePort ArgoCD UI для проброса через k3d loadbalancer"
  type        = number
  default     = 30090
}

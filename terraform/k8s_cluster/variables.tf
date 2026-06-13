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

variable "kubeconfig_path" {
  description = "Абсолютный путь на хосте для kubeconfig (рядом пишется <path>-runner для CI)"
  type        = string
}

variable "registries_config_path" {
  description = "Абсолютный путь на хосте для k3d registries.yaml"
  type        = string
}

variable "api_host_port" {
  description = "Порт Kubernetes API на хосте (k3d --api-port)"
  type        = number
}

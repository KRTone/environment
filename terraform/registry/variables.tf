variable "network_name" {
  description = "Имя Docker-сети (создаётся в корневом terraform/network.tf)"
  type        = string
}

variable "container_name" {
  description = "Имя контейнера Docker registry"
  type        = string
  default     = "environment-registry"
}

variable "registry_port" {
  description = "Порт registry на хосте (push/pull образов CI)"
  type        = number
  default     = 30500
}

variable "registry_image" {
  description = "Docker-образ registry"
  type        = string
  default     = "registry:2"
}

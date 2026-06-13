variable "network_name" {
  description = "Имя Docker-сети (создаётся в корневом terraform/network.tf)"
  type        = string
}

variable "container_name" {
  description = "Имя контейнера Docker registry (DNS-имя в сети)"
  type        = string
  default     = "docker-registry"
}

variable "registry_image" {
  description = "Docker-образ registry"
  type        = string
  default     = "registry:2"
}

variable "registry_port" {
  description = "Внутренний порт registry в Docker-сети"
  type        = number
  default     = 5000
}

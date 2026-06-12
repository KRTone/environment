variable "act_runner_image" {
  description = "Docker-образ Gitea Actions runner (тег latest — всегда актуальная версия из registry)"
  type        = string
  default     = "gitea/act_runner:latest"
}

variable "network_name" {
  description = "Имя Docker-сети (создаётся в корневом terraform/network.tf)"
  type        = string
}

variable "gitea_container_hostname" {
  description = "Имя контейнера Gitea в Docker-сети"
  type        = string
  default     = "gitea"
}

variable "gitea_port" {
  description = "Порт Gitea внутри Docker-сети"
  type        = number
  default     = 3000
}

variable "runner_registration_token" {
  description = "Токен регистрации runner (output runner_registration_token из модуля gitea)"
  type        = string
  sensitive   = true
}

variable "runner_name" {
  description = "Имя runner в Gitea"
  type        = string
  default     = "gitea-docker-runner"
}

variable "runner_labels" {
  description = "Метки runner"
  type        = string
  default     = "self-hosted,linux,docker"
}

variable "docker_socket_path" {
  description = "Путь к Docker socket на хосте runner"
  type        = string
  default     = "/var/run/docker.sock"
}

variable "container_name" {
  description = "Имя контейнера runner"
  type        = string
  default     = "gitea-act-runner"
}

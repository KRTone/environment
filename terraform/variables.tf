variable "network_name" {
  description = "Имя общей Docker-сети для Gitea и act_runner"
  type        = string
  default     = "environment-network"
}

# --- Gitea ---

variable "gitea_image" {
  description = "Docker-образ Gitea"
  type        = string
  default     = "gitea/gitea:latest"
}

variable "gitea_port" {
  description = "Порт веб-интерфейса Gitea на хосте"
  type        = number
  default     = 3000
}

variable "gitea_ssh_port" {
  description = "Порт SSH Gitea на хосте"
  type        = number
  default     = 2222
}

variable "gitea_root_url" {
  description = "Публичный URL Gitea"
  type        = string
  default     = "http://localhost:3000"
}

variable "admin_username" {
  description = "Логин администратора Gitea"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Пароль администратора Gitea"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "admin_email" {
  description = "Email администратора Gitea"
  type        = string
  default     = "admin@admin.admin"
}

# --- act_runner ---

variable "act_runner_image" {
  description = "Docker-образ Gitea Actions runner (тег latest — всегда актуальная версия из registry)"
  type        = string
  default     = "gitea/act_runner:latest"
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

variable "runner_container_name" {
  description = "Имя контейнера runner"
  type        = string
  default     = "gitea-act-runner"
}

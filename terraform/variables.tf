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

variable "gitea_actions_url" {
  description = "URL для загрузки Actions (actions/checkout). Пусто — http://gitea:<port> внутри Docker-сети"
  type        = string
  default     = ""
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
  description = "Имя локально собираемого образа act_runner (на базе gitea/act_runner + nodejs)"
  type        = string
  default     = "environment-act-runner:latest"
}

variable "runner_name" {
  description = "Имя runner в Gitea"
  type        = string
  default     = "gitea-docker-runner"
}

variable "runner_labels" {
  description = "Метки runner с Docker-образами для job-контейнеров"
  type        = string
  default     = "self-hosted:docker://node:20-bookworm,linux:docker://node:20-bookworm,docker:docker://docker:24-cli"
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

# --- Docker registry (для CI deploy в Kubernetes) ---

variable "registry_port" {
  description = "Порт на хосте для Docker registry (push/pull образов CI)"
  type        = number
  default     = 30500
}

variable "registry_container_name" {
  description = "Имя контейнера Docker registry"
  type        = string
  default     = "environment-registry"
}

variable "kubeconfig_host_path" {
  description = "Путь к kubeconfig на хосте (Docker Desktop Kubernetes). Пусто — ~/.kube/config"
  type        = string
  default     = ""
}

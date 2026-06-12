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

# --- .NET repository & Kubernetes ---

variable "create_dotnet_repo" {
  description = "Создать .NET репозиторий в Gitea с workflow CI/CD"
  type        = bool
  default     = true
}

variable "dotnet_repo_name" {
  description = "Имя .NET репозитория в Gitea"
  type        = string
  default     = "dotnet-app"
}

variable "dotnet_repo_owner" {
  description = "Владелец .NET репозитория (пользователь Gitea)"
  type        = string
  default     = "admin"
}

variable "dotnet_image_name" {
  description = "Имя Docker-образа и Kubernetes deployment"
  type        = string
  default     = "dotnet-app"
}

variable "k8s_namespace" {
  description = "Kubernetes namespace для deploy"
  type        = string
  default     = "environment"
}

variable "k8s_node_port" {
  description = "NodePort для сервиса .NET приложения"
  type        = number
  default     = 30080
}

variable "k8s_registry_node_port" {
  description = "NodePort для in-cluster Docker registry (push/pull образов CI)"
  type        = number
  default     = 30500
}

variable "kubeconfig_host_path" {
  description = "Путь к kubeconfig на хосте (Docker Desktop Kubernetes). Пусто — ~/.kube/config"
  type        = string
  default     = ""
}

variable "mount_kubeconfig_in_runner" {
  description = "Смонтировать kubeconfig в act_runner для deploy job'ов"
  type        = bool
  default     = true
}

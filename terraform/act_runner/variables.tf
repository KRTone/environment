variable "act_runner_image" {
  description = "Имя локально собираемого образа act_runner (Dockerfile с nodejs)"
  type        = string
  default     = "gitea-act-runner:local"
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
  description = "Метки runner с привязкой к Docker-образам (не :host — иначе нужен node на runner)"
  type        = string
  default     = "self-hosted:docker://node:20-bookworm,linux:docker://node:20-bookworm,docker:docker://docker:24-cli"
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

variable "kubeconfig_host_path" {
  description = "Путь к kubeconfig на хосте для deploy в Kubernetes"
  type        = string
  default     = ""
}

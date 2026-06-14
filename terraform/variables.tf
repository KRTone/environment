# --- Gitea ---

variable "gitea_image" {
  description = "Docker-образ Gitea"
  type        = string
  default     = "gitea/gitea:latest"
}

variable "gitea_port" {
  description = "HTTP-порт Gitea в Docker-сети"
  type        = number
  default     = 3000
}

variable "gitea_ssh_port" {
  description = "SSH-порт Gitea (проброс на хост для git по SSH)"
  type        = number
  default     = 2222
}

variable "gitea_root_url" {
  description = "URL Gitea в Docker-сети (используется в ссылках Gitea и Actions)"
  type        = string
  default     = "http://gitea:3000"
}

variable "gitea_actions_url" {
  description = "URL для загрузки Actions. Пусто — http://gitea:<port> в Docker-сети"
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

variable "runner_registration_token" {
  description = "Статический токен регистрации Gitea Actions runner"
  type        = string
  default     = "gitea-actions-runner-registration-token"
  sensitive   = true
}

# --- act_runner ---

variable "act_runner_image" {
  description = "Имя локально собираемого образа act_runner"
  type        = string
  default     = "gitea-act-runner:local"
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

# --- Docker registry ---

variable "registry_container_name" {
  description = "DNS-имя Docker registry в сети gitea-network"
  type        = string
  default     = "docker-registry"
}

variable "registry_host_port" {
  description = "Порт Docker registry на хосте для push из CI (docker push через daemon)"
  type        = number
  default     = 30500
}

# --- Kubernetes (k3d) ---

variable "create_k8s_cluster" {
  description = "Создать k3d-кластер в Docker-сети gitea-network"
  type        = bool
  default     = true
}

variable "k8s_cluster_name" {
  description = "Имя k3d-кластера"
  type        = string
  default     = "local"
}

variable "k8s_api_host_port" {
  description = "Порт Kubernetes API на хосте (k3d --api-port)"
  type        = number
  default     = 6443
}

variable "kubeconfig_host_path" {
  description = "Путь к kubeconfig на хосте, если create_k8s_cluster = false"
  type        = string
  default     = ""
}

# --- ArgoCD / GitOps ---

variable "install_argocd" {
  description = "Установить ArgoCD (Helm). Repository и Application создаются вручную"
  type        = bool
  default     = true
}

variable "argocd_helm_chart_version" {
  description = "Версия Helm chart argo-cd"
  type        = string
  default     = "7.7.16"
}

variable "argocd_ui_node_port" {
  description = "NodePort HTTP для UI ArgoCD"
  type        = number
  default     = 30090
}

variable "argocd_admin_password" {
  description = "Пароль admin ArgoCD (bcrypt-хеш в argocd/values/argocd-values.yaml)"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "argocd_app_namespace" {
  description = "Namespace приложений (создаётся Terraform; GitOps-ресурсы — вручную)"
  type        = string
  default     = "apps"
}

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
  description = "Публичный URL Gitea (используется в ссылках и для подключения runner)"
  type        = string
  default     = "http://localhost:3000"
}

variable "gitea_actions_url" {
  description = "URL для загрузки Gitea Actions (actions/checkout и др.). Пусто — http://gitea:<port> (доступно из Docker-сети runner)"
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

variable "network_name" {
  description = "Имя Docker-сети (создаётся в корневом terraform/network.tf)"
  type        = string
}

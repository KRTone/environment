provider "docker" {}

provider "kubernetes" {
  host                   = var.create_k8s_cluster ? module.k8s_cluster[0].host : null
  client_certificate     = var.create_k8s_cluster ? base64decode(module.k8s_cluster[0].client_certificate) : null
  client_key             = var.create_k8s_cluster ? base64decode(module.k8s_cluster[0].client_key) : null
  cluster_ca_certificate = var.create_k8s_cluster ? base64decode(module.k8s_cluster[0].cluster_ca_certificate) : null
  config_path            = var.create_k8s_cluster ? null : local.kubeconfig_user_path
}

provider "helm" {
  kubernetes {
    host                   = var.create_k8s_cluster ? module.k8s_cluster[0].host : null
    client_certificate     = var.create_k8s_cluster ? base64decode(module.k8s_cluster[0].client_certificate) : null
    client_key             = var.create_k8s_cluster ? base64decode(module.k8s_cluster[0].client_key) : null
    cluster_ca_certificate = var.create_k8s_cluster ? base64decode(module.k8s_cluster[0].cluster_ca_certificate) : null
    config_path            = var.create_k8s_cluster ? null : local.kubeconfig_user_path
  }
}

provider "gitea" {
  base_url = "http://127.0.0.1:${var.gitea_port}"
  username = var.admin_username
  password = var.admin_password
  insecure = true
}

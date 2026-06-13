locals {
  kubeconfig_user_path             = var.kubeconfig_host_path != "" ? replace(var.kubeconfig_host_path, "\\", "/") : replace(pathexpand("~/.kube/config"), "\\", "/")
  kubeconfig_generated_path        = replace(abspath("${path.module}/.generated/kubeconfig-${var.k8s_cluster_name}"), "\\", "/")
  kubeconfig_runner_generated_path = replace(abspath("${path.module}/.generated/kubeconfig-${var.k8s_cluster_name}-runner"), "\\", "/")
  kubeconfig_host_path             = var.create_k8s_cluster ? local.kubeconfig_generated_path : local.kubeconfig_user_path
  kubeconfig_runner_path           = var.create_k8s_cluster ? local.kubeconfig_runner_generated_path : local.kubeconfig_user_path
}

module "gitea" {
  source = "./gitea"

  network_name = docker_network.gitea.name

  gitea_image       = var.gitea_image
  gitea_port        = var.gitea_port
  gitea_ssh_port    = var.gitea_ssh_port
  gitea_root_url    = var.gitea_root_url
  gitea_actions_url = var.gitea_actions_url
  admin_username    = var.admin_username
  admin_password    = var.admin_password
  admin_email       = var.admin_email
}

module "docker_registry" {
  source = "./docker_registry"

  network_name   = docker_network.gitea.name
  container_name = var.registry_container_name
}

module "k8s_cluster" {
  source = "./k8s_cluster"
  count  = var.create_k8s_cluster ? 1 : 0

  depends_on = [module.docker_registry]

  cluster_name           = var.k8s_cluster_name
  network_name           = docker_network.gitea.name
  registry_address       = module.docker_registry.registry_address
  kubeconfig_path        = local.kubeconfig_generated_path
  registries_config_path = replace(abspath("${path.module}/.generated/k3d-registries.yaml"), "\\", "/")
  api_host_port          = var.k8s_api_host_port
}

module "act_runner" {
  source = "./act_runner"

  depends_on = [module.gitea, module.k8s_cluster]

  act_runner_image          = var.act_runner_image
  network_name              = docker_network.gitea.name
  gitea_container_hostname  = module.gitea.gitea_container_name
  gitea_port                = var.gitea_port
  runner_registration_token = module.gitea.runner_registration_token
  runner_name               = var.runner_name
  runner_labels             = var.runner_labels
  docker_socket_path        = var.docker_socket_path
  container_name            = var.runner_container_name
  kubeconfig_host_path      = local.kubeconfig_runner_path
}

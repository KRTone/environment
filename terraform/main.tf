module "gitea" {
  source = "./gitea"

  network_name = docker_network.gitea.name

  gitea_image     = var.gitea_image
  gitea_port      = var.gitea_port
  gitea_ssh_port  = var.gitea_ssh_port
  gitea_root_url    = var.gitea_root_url
  gitea_actions_url = var.gitea_actions_url
  admin_username    = var.admin_username
  admin_password  = var.admin_password
  admin_email     = var.admin_email
}

module "act_runner" {
  source = "./act_runner"

  depends_on = [module.gitea]

  act_runner_image         = var.act_runner_image
  network_name             = docker_network.gitea.name
  gitea_container_hostname = module.gitea.gitea_container_name
  gitea_port = var.gitea_port
  runner_registration_token = module.gitea.runner_registration_token
  runner_name = var.runner_name
  runner_labels = var.runner_labels
  docker_socket_path       = var.docker_socket_path
  container_name           = var.runner_container_name
  kubeconfig_host_path     = local.kubeconfig_host_path
  mount_kubeconfig         = var.mount_kubeconfig_in_runner
}

module "registry" {
  source = "./registry"
  count  = var.create_registry ? 1 : 0

  network_name   = docker_network.gitea.name
  registry_port  = var.registry_port
  container_name = var.registry_container_name
}

locals {
  kubeconfig_host_path = var.kubeconfig_host_path != "" ? replace(var.kubeconfig_host_path, "\\", "/") : replace(pathexpand("~/.kube/config"), "\\", "/")

  dotnet_template_vars = {
    k8s_namespace          = var.k8s_namespace
    image_name             = var.dotnet_image_name
    k8s_node_port          = var.k8s_node_port
    k8s_registry_node_port   = var.k8s_registry_node_port
    kubeconfig_host_path   = local.kubeconfig_host_path
    runner_label           = "self-hosted"
    gitea_host             = "gitea"
    gitea_port             = var.gitea_port
  }

  dotnet_workflow = var.create_dotnet_repo ? templatefile(
    "${path.module}/templates/dotnet/.gitea/workflows/ci.yml.tpl",
    local.dotnet_template_vars
  ) : ""

  dotnet_k8s_namespace = var.create_dotnet_repo ? templatefile(
    "${path.module}/templates/dotnet/k8s/namespace.yaml",
    local.dotnet_template_vars
  ) : ""

  dotnet_k8s_deployment = var.create_dotnet_repo ? templatefile(
    "${path.module}/templates/dotnet/k8s/deployment.yaml",
    local.dotnet_template_vars
  ) : ""

  dotnet_k8s_service = var.create_dotnet_repo ? templatefile(
    "${path.module}/templates/dotnet/k8s/service.yaml",
    local.dotnet_template_vars
  ) : ""
}

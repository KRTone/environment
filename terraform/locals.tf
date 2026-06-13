locals {
  kubeconfig_host_path = var.kubeconfig_host_path != "" ? replace(var.kubeconfig_host_path, "\\", "/") : replace(pathexpand("~/.kube/config"), "\\", "/")
}

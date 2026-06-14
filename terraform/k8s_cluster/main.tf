resource "k3d_cluster" "this" {
  name = var.cluster_name

  k3d_config = <<-EOF
apiVersion: k3d.io/v1alpha4
kind: Simple
network: ${var.network_name}
servers: 1
kubeAPI:
  host: "127.0.0.1"
  hostIP: "127.0.0.1"
  hostPort: "${var.api_host_port}"
ports:
  - port: ${var.argocd_ui_node_port}:${var.argocd_ui_node_port}
    nodeFilters:
      - loadbalancer
registries:
  config: |
    mirrors:
      "${var.registry_address}":
        endpoint:
          - http://${var.registry_address}
    configs:
      "${var.registry_address}":
        tls:
          insecure_skip_verify: true
options:
  k3s:
    extraArgs:
      - arg: --tls-san=k3d-${var.cluster_name}-server-0
        nodeFilters:
          - server:*
      - arg: --tls-san=127.0.0.1
        nodeFilters:
          - server:*
EOF
}

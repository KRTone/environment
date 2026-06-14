resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      managed-by = "terraform"
      purpose    = "gitops"
    }
  }
}

resource "kubernetes_namespace" "apps" {
  metadata {
    name = var.app_namespace
    labels = {
      managed-by = "terraform"
    }
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = var.helm_chart_version

  values = [file("${path.module}/values/argocd-values.yaml")]

  timeout       = 600
  wait          = true
  wait_for_jobs = true

  depends_on = [kubernetes_namespace.argocd]
}

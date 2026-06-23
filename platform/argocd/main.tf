resource "kubernetes_namespace" "argocd" {

  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  version = "8.2.5"

  namespace = kubernetes_namespace.argocd.metadata[0].name

  create_namespace = false

  wait    = true
  timeout = 900

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

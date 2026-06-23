resource "kubernetes_namespace" "monitoring" {

  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "kube_prometheus_stack" {

  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  version = "78.5.0"

  namespace = "monitoring"

  create_namespace = false

  values = [
    file("${path.module}/grafana-values.yaml")
  ]

  timeout = 1200

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

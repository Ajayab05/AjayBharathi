resource "helm_release" "loki" {

  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"

  version = "2.10.2"

  namespace = "monitoring"

  create_namespace = false

  values = [
    file("${path.module}/loki-values.yaml")
  ]

  timeout = 900
}

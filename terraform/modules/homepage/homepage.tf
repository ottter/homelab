resource "kubernetes_namespace" "ns" {
  metadata {
    labels = {
      istio-injection = "enabled"
    }
    name = "homepage"
  }
}

# https://truecharts.org/charts/stable/homepage/
resource "helm_release" "homepage" {
  name      = "homepage"
  namespace = kubernetes_namespace.ns.metadata[0].name

  repository = "oci://tccr.io/truecharts"
  chart      = "homepage"

  values = [
    templatefile("${path.module}/values-tmpl.yaml", {
      tls_secret = kubernetes_secret.tls.metadata[0].name
      full_path  = "${var.domain_sub}.${var.domain_root}"
    })
  ]
}
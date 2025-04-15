resource "kubernetes_namespace" "ns" {
  metadata {
    labels = {
      istio-injection = "enabled"
    }
    name = "transmission"
  }
}

# https://truecharts.org/charts/stable/transmission/
resource "helm_release" "transmission" {
  name      = "transmission"
  namespace = kubernetes_namespace.ns.metadata[0].name

  repository = "oci://tccr.io/truecharts"
  chart      = "transmission"

  values = [
    templatefile("${path.module}/values-tmpl.yaml", {
      tls_secret          = kubernetes_secret.tls.metadata[0].name
      full_path           = "${var.domain_sub}.${var.domain_root}"
      plexdir_downloads   = "${var.plexdir_downloads}"
      transmission_config = "${var.transmission_config}"
      username            = "${var.username}"
      password            = "${var.password}"
    })
  ]
}



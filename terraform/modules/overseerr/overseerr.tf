resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = "overseerr"
  }
}

# https://truecharts.org/charts/stable/overseerr/
resource "helm_release" "overseerr" {
  name      = "overseerr"
  namespace = kubernetes_namespace_v1.ns.metadata[0].name

  repository = "oci://oci.trueforge.org/truecharts"
  chart      = "overseerr"

  values = [
    templatefile("${path.module}/values-tmpl.yaml", {
      tls_secret       = "${kubernetes_namespace_v1.ns.metadata[0].name}-tls"
      full_path        = "${var.domain_sub}.${var.domain_root}"
      homepage_enabled = var.homepage_enabled
    })
  ]
}

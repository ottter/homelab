resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = "transmission"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

# https://truecharts.org/charts/stable/transmission/
resource "helm_release" "transmission" {
  name      = "transmission"
  namespace = kubernetes_namespace_v1.ns.metadata[0].name

  repository = "oci://oci.trueforge.org/truecharts"
  chart      = "transmission"

  values = [
    templatefile("${path.module}/values-tmpl.yaml", {
      tls_secret          = "${kubernetes_namespace_v1.ns.metadata[0].name}-tls"
      full_path           = "${var.domain_sub}.${var.domain_root}"
      homepage_enabled    = var.homepage_enabled
      plexdir_downloads   = var.plexdir_downloads
      transmission_config = var.transmission_config
      username            = var.username
      password            = var.password
    })
  ]
}

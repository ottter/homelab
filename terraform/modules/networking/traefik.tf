resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  namespace  = kubernetes_namespace.traefik.metadata[0].name
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"

  values = [
    templatefile("${path.module}/traefik-values.yaml", {
      traefik_lb_ip = local.traefik_lb_ip
    })
  ]

  depends_on = [kubernetes_manifest.l2_advertisement]
}

# Middleware: restrict Transmission to LAN only
resource "kubernetes_manifest" "local_ipallowlist" {
  depends_on = [helm_release.traefik]

  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "local-ipallowlist"
      namespace = kubernetes_namespace.traefik.metadata[0].name
    }
    spec = {
      ipAllowList = {
        sourceRange = ["192.168.0.0/16", "10.0.0.0/8", "127.0.0.1/32"]
      }
    }
  }
}

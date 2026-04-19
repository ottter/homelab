resource "kubernetes_namespace" "ns" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  namespace  = kubernetes_namespace.ns.metadata[0].name
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"

  values = [
    file("${path.module}/values-tmpl.yaml")
  ]
}

# Middleware: restrict Transmission to LAN only (replaces nginx whitelist annotation)
resource "kubernetes_manifest" "local_ipallowlist" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "local-ipallowlist"
      namespace = kubernetes_namespace.ns.metadata[0].name
    }
    spec = {
      ipAllowList = {
        sourceRange = ["192.168.0.0/16", "10.0.0.0/8", "127.0.0.1/32"]
      }
    }
  }
}

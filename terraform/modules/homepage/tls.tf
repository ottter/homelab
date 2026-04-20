resource "kubernetes_manifest" "certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "${kubernetes_namespace.ns.metadata[0].name}-tls"
      namespace = kubernetes_namespace.ns.metadata[0].name
    }
    spec = {
      secretName = "${kubernetes_namespace.ns.metadata[0].name}-tls"
      issuerRef = {
        name  = "homelab-ca"
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
      dnsNames = ["${var.domain_sub}.${var.domain_root}"]
    }
  }
}

resource "kubernetes_ingress_v1" "yamtrack" {
  metadata {
    name      = "yamtrack-ingress"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
  }

  spec {
    ingress_class_name = "traefik"

    tls {
      hosts       = ["${var.domain_sub}.${var.domain_root}"]
      secret_name = "${kubernetes_namespace_v1.ns.metadata[0].name}-tls"
    }

    rule {
      host = "${var.domain_sub}.${var.domain_root}"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.yamtrack.metadata[0].name
              port {
                number = 8000
              }
            }
          }
        }
      }
    }
  }
}

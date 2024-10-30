resource "kubernetes_service" "plex" {
  metadata {
    name      = "plex-service"
    namespace = kubernetes_namespace.ns.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" : "nginx" # Using Nginx ingress
    }
  }

  spec {
    selector = {
      app = "plex"
    }

    port {
      name        = "http"
      port        = 32400
      target_port = 32400
      node_port  = 32000
    }

    type = "NodePort"
  }
}

# resource "kubernetes_ingress" "plex_ingress" {
#   metadata {
#     name      = "plex-ingress"
#     namespace = kubernetes_namespace.ns.metadata[0].name
#     annotations = {
#       "nginx.ingress.kubernetes.io/ssl-redirect"     = "true"
#     }
#   }

#   spec {
#     ingress_class_name = "nginx"
#     rule {
#       host = "plex.${var.domain_root}"
#       http {
#         path {
#           path = "/"
#           backend {
#             service_name = kubernetes_service.plex.metadata[0].name
#             service_port = 32400
#           }
#         }
#       }
#     }
#     tls {
#       hosts       = ["plex.${var.domain_root}"]
#       secret_name = kubernetes_secret.tls.metadata[0].name
#     }
#   }
# }

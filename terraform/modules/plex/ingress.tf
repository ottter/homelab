resource "kubernetes_service" "plex" {
  metadata {
    name      = "plex-service"
    namespace = kubernetes_namespace.ns.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" : "nginx"
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
      node_port   = 32000
    }

    type = "NodePort"
  }
}

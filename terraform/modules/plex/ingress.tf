resource "kubernetes_service_v1" "plex" {
  metadata {
    name      = "plex-service"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
    annotations = {
      "metallb.universe.tf/loadBalancerIPs" = var.plex_lb_ip
    }
  }

  spec {
    selector = {
      app = "plex"
    }

    port {
      name        = "plex"
      port        = 32400
      target_port = 32400
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_namespace" "ns" {
  metadata {
    labels = {
      istio-injection = "enabled"
    }
    name = "plex"
  }
}

resource "kubernetes_deployment" "plex" {
  metadata {
    name      = "plex"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "plex"
      }
    }

    template {
      metadata {
        labels = {
          app = "plex"
        }
      }

      spec {
        hostname = "plex"

        container {
          name  = "plex"
          image = var.plex_image

          port {
            container_port = 32400
          }

          env {
            name  = "PLEX_CLAIM"
            value = var.plex_token
          }

          volume_mount {
            name       = "config"
            mount_path = "/config"
          }

          volume_mount {
            name       = "transcode"
            mount_path = "/transcode"
          }

          volume_mount {
            name       = "media"
            mount_path = "/media"
          }
        }

        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.plex_config_pvc.metadata[0].name
          }
        }

        volume {
          name = "transcode"
          empty_dir {}
        }

        volume {
          name = "media"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.plex_media_pvc.metadata[0].name
          }
        }
      }
    }
  }
}
resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = "plex"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

resource "kubernetes_deployment_v1" "plex" {
  metadata {
    name      = "plex"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
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
        container {
          name  = "plex"
          image = "lscr.io/linuxserver/plex:latest"

          env {
            name  = "PUID"
            value = "1000"
          }
          env {
            name  = "PGID"
            value = "1000"
          }
          env {
            name  = "TZ"
            value = "America/New_York"
          }
          env {
            name  = "VERSION"
            value = "docker"
          }
          env {
            name  = "PLEX_CLAIM"
            value = var.plex_token
          }
          volume_mount {
            name       = "plex-config"
            mount_path = "/config"
          }
          volume_mount {
            name       = "tv-series"
            mount_path = "/tv"
          }
          volume_mount {
            name       = "movies"
            mount_path = "/movies"
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 32400
            }
            initial_delay_seconds = 60
            period_seconds        = 30
            failure_threshold     = 3
          }
        }

        volume {
          name = "plex-config"
          host_path {
            path = var.plex_path_config
            type = "Directory"
          }
        }
        volume {
          name = "tv-series"
          host_path {
            path = var.plex_path_tv
            type = "Directory"
          }
        }
        volume {
          name = "movies"
          host_path {
            path = var.plex_path_movies
            type = "Directory"
          }
        }
      }
    }
  }
}

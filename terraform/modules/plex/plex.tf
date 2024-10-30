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
            value = "Etc/UTC"
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
        }

        volume {
          name = "plex-config"
          host_path {
            path = var.plex_path_config
          }
        }
        volume {
          name = "tv-series"
          host_path {
            path = var.plex_path_tv
          }
        }
        volume {
          name = "movies"
          host_path {
            path = var.plex_path_movies
          }
        }
      }
    }
  }
}

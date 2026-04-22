resource "random_password" "secret" {
  length  = 64
  special = false
}

resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = "yamtrack"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

resource "kubernetes_deployment_v1" "yamtrack" {
  metadata {
    name      = "yamtrack"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "yamtrack"
      }
    }

    template {
      metadata {
        labels = {
          app = "yamtrack"
        }
      }

      spec {
        container {
          name  = "yamtrack"
          image = "ghcr.io/fuzzygrim/yamtrack:latest"

          port {
            container_port = 8000
          }

          env {
            name  = "SECRET"
            value = random_password.secret.result
          }
          env {
            name  = "REDIS_URL"
            value = "redis://localhost:6379"
          }
          env {
            name  = "TZ"
            value = "America/New_York"
          }
          env {
            name  = "URLS"
            value = "https://${var.domain_sub}.${var.domain_root}"
          }
          volume_mount {
            name       = "yamtrack-db"
            mount_path = "/yamtrack/db"
          }
        }

        container {
          name  = "redis"
          image = "redis:8-alpine"
        }

        volume {
          name = "yamtrack-db"
          host_path {
            path = var.yamtrack_path_db
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "yamtrack" {
  metadata {
    name      = "yamtrack-service"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
  }

  spec {
    selector = {
      app = "yamtrack"
    }

    port {
      name        = "http"
      port        = 8000
      target_port = 8000
    }

    type = "ClusterIP"
  }
}

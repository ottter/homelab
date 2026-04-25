resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = var.bot_name
  }
}

resource "kubernetes_deployment_v1" "discord_bot" {
  metadata {
    name      = var.bot_name
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
    labels = {
      app = var.bot_name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.bot_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.bot_name
        }
      }

      spec {
        container {
          name              = var.bot_name
          image             = var.discord_image
          image_pull_policy = "IfNotPresent"

          env {
            name = "DISCORD_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.discord_bot_secret.metadata[0].name
                key  = "discord_token"
              }
            }
          }
        }

        image_pull_secrets {
          name = kubernetes_secret_v1.ghcr_secret.metadata[0].name
        }
      }
    }
  }
}

resource "kubernetes_secret_v1" "discord_bot_secret" {
  metadata {
    name      = "${var.bot_name}-secrets"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
  }

  data = {
    discord_token = var.discord_token
  }
}

resource "kubernetes_secret_v1" "ghcr_secret" {
  metadata {
    name      = "${var.bot_name}-ghcr"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          auth = base64encode("${var.github_username}:${var.github_pat}")
        }
      }
    })
  }
}

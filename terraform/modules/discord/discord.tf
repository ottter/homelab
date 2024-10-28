resource "kubernetes_namespace" "ns" {
  metadata {
    labels = {
      istio-injection = "enabled"
    }
    name = "discord"
  }
}


resource "kubernetes_deployment" "discord_bot" {
  metadata {
    name      = "discord-bot"
    namespace = kubernetes_namespace.ns.metadata[0].name
    labels = {
      app = "discord-bot"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "discord-bot"
      }
    }

    template {
      metadata {
        labels = {
          app = "discord-bot"
        }
      }

      spec {
        container {
          name              = "discord-bot"
          image             = var.discord_image
          image_pull_policy = "Always"

          # env {
          #   name = "DISCORD_TOKEN"
          #   value_from {
          #     secret_key_ref {
          #       name = kubernetes_secret.discord_bot_secret.metadata[0].name
          #       key  = "discord_token"
          #     }
          #   }
          # }
        }

        image_pull_secrets {
          name = kubernetes_secret.ghcr_secret.metadata[0].name
        }
      }
    }
  }
}

# resource "kubernetes_secret" "discord_bot_secret" {
#   metadata {
#     name      = "discord-bot-secrets"
#     namespace = kubernetes_namespace.ns.metadata[0].name
#   }

#   data = {
#     discord_token = base64encode(var.discord_token)
#   }
# }

resource "kubernetes_secret" "ghcr_secret" {
  metadata {
    name      = "ghcr-secret"
    namespace = kubernetes_namespace.ns.metadata[0].name
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

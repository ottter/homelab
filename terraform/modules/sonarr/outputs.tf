data "kubernetes_secret_v1" "sonarr_key" {
  count = var.homepage_enabled ? 1 : 0
  metadata {
    name      = "homepage-api-key-sonarr"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
  }
}

output "sonarr_api_key" {
  value     = var.homepage_enabled ? try(data.kubernetes_secret_v1.sonarr_key[0].data["apiKey"], "") : ""
  sensitive = true
}
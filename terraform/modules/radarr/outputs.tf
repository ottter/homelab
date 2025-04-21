data "kubernetes_secret" "radarr_key" {
  metadata {
    name      = "homepage-api-key-radarr"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
}

output "radarr_api_key" {
  value     = data.kubernetes_secret.radarr_key.data["apiKey"]
  sensitive = true
}
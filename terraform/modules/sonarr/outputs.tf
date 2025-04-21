data "kubernetes_secret" "sonarr_key" {
  metadata {
    name      = "homepage-api-key-sonarr"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
}

output "sonarr_api_key" {
  value     = data.kubernetes_secret.sonarr_key.data["apiKey"]
  sensitive = true
}
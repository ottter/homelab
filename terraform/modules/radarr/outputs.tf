# data "kubernetes_secret" "radarr_api" {
#   metadata {
#     name      = "radarr-api-key"
#     namespace = "radarr"
#   }
# }

# output "radarr_api_key" {
#   value = base64decode(data.kubernetes_secret.radarr_api.data["apiKey"])
# }
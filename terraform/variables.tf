variable "kubeconfig" {
  default     = "~/.kube/config"
  description = "Location of kube config file to access cluster"
}
variable "domain_root" {
  default     = "local"
  description = "Root domain name for the environment. (.local; homelab.local)"
}
variable "node_ip" {
  default     = ["192.168.0.144"]
  description = "A List of IP Addresses associated with the cluster"
  type        = list(any)
}
variable "kubecost_token" {
  description = "Kubecost token. A free trial one can be gotten from https://www.kubecost.com/install.html"
  sensitive   = true
}
variable "discord_image" {
  description = "Name of Docker image to deploy"
  # Should in theory work with any Docker image but I am using it for a discord bot
}
variable "github_username" {
  description = "Github Username to access image on Github Container Registry"
}
variable "github_pat" {
  description = "Github PAT to access image on Github Container Registry"
  sensitive   = true
}
variable "apikey_finnhub" {
  default     = "apikey"
  description = "API key from https://finnhub.io/"
  type        = string
  sensitive   = true
}
variable "apikey_openweathermap" {
  default     = "apikey"
  description = "API key from https://openweathermap.org/"
  type        = string
  sensitive   = true
}
variable "apikey_weatherapi" {
  default     = "apikey"
  description = "API key from https://www.weatherapi.com/"
  type        = string
  sensitive   = true
}
variable "plex_token" {
  default     = "apikey"
  description = "Create a Plex account and get a token from https://www.plex.tv/claim/"
  sensitive   = true
}
variable "plex_path_config" {
  default     = "/mnt/plex/config"
  description = "Filepath on NFS share for Plex config"
}
variable "plex_path_downloads" {
  default     = "/mnt/plex/downloads"
  description = ""
}
variable "plex_path_tv" {
  default     = "/mnt/plex/tv"
  description = "Filepath on NFS share for Plex tv"
}
variable "plex_path_movies" {
  default     = "/mnt/plex/movies"
  description = "Filepath on NFS share for Plex movies"
}
variable "plex_path_root" {
  default     = "/mnt/plex"
  description = "Filepath on NFS share for Plex root location"
}
variable "stock_watchlist" {
  default     = ["SPY", "NVDA", "TSM", "MSFT", "AAPL"]
  description = "List of stock ticker symbols (compatible with Finnhub API)"
  type        = list(string)
}
variable "transmission_user" {
  default     = "admin"
  description = "Basic Auth username to access Transmission. Can be disabled in values.yaml"
}
variable "transmission_pass" {
  default     = "password"
  description = "Basic Auth password to access Transmission. Can be disabled in values.yaml"
}
variable "enable_discord" {
  default     = false
  description = "Enable the Discord module"
  type        = bool
}
variable "enable_homepage" {
  default     = false
  description = "Enable the Homepage module"
  type        = bool
}
variable "enable_kubecost" {
  default     = false
  description = "Enable the Kubecost module"
  type        = bool
}
variable "enable_plex" {
  default     = false
  description = "Enable the Plex module"
  type        = bool
}
variable "enable_radarr" {
  default     = false
  description = "Enable the Radarr module"
  type        = bool
}
variable "enable_sonarr" {
  default     = false
  description = "Enable the Sonarr module"
  type        = bool
}
variable "enable_transmission" {
  default     = false
  description = "Enable the Transmission module"
  type        = bool
}
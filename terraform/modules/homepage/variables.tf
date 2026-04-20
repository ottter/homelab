variable "domain_root" {
  default = "local"
  type    = string
}

variable "domain_sub" {
  default = "homepage"
  type    = string
}

variable "apikey_finnhub" {
  default     = "apikey"
  description = "API key from https://finnhub.io/"
  type        = string
  sensitive   = true
}

variable "apikey_sonarr" {
  default     = ""
  description = "API Key from Sonarr"
  type        = string
  sensitive   = true
}

variable "apikey_radarr" {
  default     = ""
  description = "API Key from Radarr"
  type        = string
  sensitive   = true
}

variable "apikey_openweathermap" {
  default     = ""
  description = "API key from https://openweathermap.org/"
  type        = string
  sensitive   = true
}

variable "apikey_weatherapi" {
  default     = ""
  description = "API key from https://www.weatherapi.com/"
  type        = string
  sensitive   = true
}

variable "plex_lb_ip" {
  type = string
}

variable "plex_token" {
  type      = string
  sensitive = true
}

variable "traefik_lb_ip" {
  type = string
}

variable "stock_watchlist" {
  default     = ["SPY", "NVDA", "TSM", "MSFT", "AAPL"]
  description = "List of stock ticker symbols (compatible with Finnhub API)"
  type        = list(string)
}

variable "transmission_user" {
  default   = ""
  type      = string
  sensitive = true
}

variable "transmission_pass" {
  default   = ""
  type      = string
  sensitive = true
}
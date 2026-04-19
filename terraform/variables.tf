variable "node_ip" {
  default     = ["192.168.0.210"]
  description = "A List of IP Addresses associated with the cluster"
  type        = list(any)
}

variable "traefik_lb_ip" {
  default     = "192.168.0.220"
  description = "LoadBalancer IP for Traefik (MetalLB). Must be first IP of metallb_pool in ansible/group_vars/all.yml."
  type        = string

  validation {
    condition     = can(regex("^(10|172\\.(1[6-9]|2[0-9]|3[01])|192\\.168)\\.", var.traefik_lb_ip))
    error_message = "traefik_lb_ip must be a private RFC1918 address (10.x, 172.16-31.x, 192.168.x)."
  }

  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}$", var.traefik_lb_ip))
    error_message = "traefik_lb_ip must be a single IP address (e.g. '192.168.0.220')."
  }
}

variable "plex_lb_ip" {
  default     = "192.168.0.221"
  description = "LoadBalancer IP for the Plex service. Must be within metallb_pool, not the first IP (used by Traefik), and must also be set in ansible/group_vars/all.yml."
  type        = string

  validation {
    condition     = can(regex("^(10|172\\.(1[6-9]|2[0-9]|3[01])|192\\.168)\\.", var.plex_lb_ip))
    error_message = "plex_lb_ip must be a private RFC1918 address (10.x, 172.16-31.x, 192.168.x)."
  }

  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}$", var.plex_lb_ip))
    error_message = "plex_lb_ip must be a single IP address (e.g. '192.168.0.221')."
  }
}

variable "kubeconfig" {
  default     = "~/.kube/config"
  description = "Location of kube config file to access cluster"
}

variable "domain_root" {
  default     = "local"
  description = "Root domain name for the environment. (.local; homelab.local)"
}

variable "discord_image" {
  default     = ""
  description = "Docker image to deploy for the Discord bot (e.g. ghcr.io/user/repo:tag)"
}

variable "github_username" {
  default     = ""
  description = "GitHub username for accessing the GitHub Container Registry"
}

variable "github_pat" {
  default     = ""
  description = "GitHub PAT for accessing the GitHub Container Registry"
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
  description = "Filepath for Transmission downloads. Must contain 'complete' and 'incomplete' subdirectories."
}

variable "plex_path_tv" {
  default     = "/mnt/plex/tv"
  description = "Filepath on NFS share for Plex tv"
}

variable "plex_path_movies" {
  default     = "/mnt/plex/movies"
  description = "Filepath on NFS share for Plex movies"
}

variable "stock_watchlist" {
  default     = ["SPY", "NVDA", "TSM", "MSFT", "AAPL"]
  description = "List of stock ticker symbols (compatible with Finnhub API)"
  type        = list(string)
}

variable "transmission_user" {
  description = "Basic Auth username to access Transmission. Can be disabled in values.yaml"
  type        = string
  sensitive   = true
}

variable "transmission_pass" {
  description = "Basic Auth password to access Transmission. Can be disabled in values.yaml"
  type        = string
  sensitive   = true
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

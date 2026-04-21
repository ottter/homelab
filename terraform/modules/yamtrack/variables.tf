variable "domain_root" {
  default     = "local"
  type        = string
  description = "Root domain name for the environment"
}

variable "domain_sub" {
  default     = "yam"
  type        = string
  description = "Subdomain for Yamtrack"
}

variable "homepage_enabled" {
  default     = true
  type        = bool
  description = "Enable Homepage integration"
}

variable "yamtrack_path_db" {
  default     = "/mnt/yamtrack/db"
  type        = string
  description = "hostPath on the node for Yamtrack database storage"
}

variable "tz" {
  default     = "America/New_York"
  type        = string
  description = "Timezone for the Yamtrack container"
}

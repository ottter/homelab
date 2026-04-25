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
  default     = "/var/lib/yamtrack/db"
  type        = string
  description = "hostPath on the node for Yamtrack database storage"
}

variable "domain_root" {
  default     = "local"
  type        = string
  description = "Root domain name for the environment"
}

variable "domain_sub" {
  default     = "overseerr"
  type        = string
  description = "Subdomain for Overseerr"
}

variable "tz" {
  default     = "America/New_York"
  type        = string
  description = "Timezone for the Overseerr container"
}

variable "homepage_enabled" {
  default     = true
  type        = bool
  description = "Enable Homepage integration"
}

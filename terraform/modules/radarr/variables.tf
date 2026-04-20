variable "domain_root" {
  default = "local"
  type    = string
}

variable "domain_sub" {
  default = "radarr"
  type    = string
}

variable "homepage_enabled" {
  default = true
  type    = bool
}

variable "nfs_enabled" {
  default = false
  type    = bool
}

variable "nfs_mount_point" {
  default = "/mnt/plex"
  type    = string
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

variable "transmission_ns" {
  default = "transmission"
  type    = string
}

variable "transmission_enabled" {
  default = true
  type    = bool
}

variable "server_ip" {
  type = string
}
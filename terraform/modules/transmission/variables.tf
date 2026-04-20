variable "domain_root" {
  default = "local"
  type    = string
}
variable "domain_sub" {
  default = "transmission"
  type    = string
}
variable "homepage_enabled" {
  default = true
  type    = bool
}
variable "plexdir_downloads" {
  default = "/mnt/plex/downloads"
}
variable "transmission_config" {
  default = "/mnt/plex/transmission/config"
}
variable "username" {
  type      = string
  sensitive = true
}
variable "password" {
  type      = string
  sensitive = true
}
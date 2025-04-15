variable "domain_root" {
  default = "local"
  type    = string
}
variable "domain_sub" {
  default = "sonarr"
  type    = string
}
variable "plexdir_tv" {
  default = "/mnt/plex/tv"
  type    = string
}
variable "transmission_user" {
  default = "admin"
  type    = string
}
variable "transmission_pass" {
  default = "password"
  type    = string
}
variable "transmission_ns" {
  default = "transmission"
  type    = string
}
variable "transmission_enabled" {
  default = true
  type    = bool
}
variable "server_ip" {}
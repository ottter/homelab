variable "domain_root" {
  default = "local"
}
variable "domain_sub" {
  default = "transmission"
}
variable "homepage_enabled" {
  default = true
  type = bool
}
variable "plexdir_downloads" {
  default = "/mnt/plex/downloads"
}
variable "transmission_config" {
  default = "/mnt/plex/transmission/config"
}
variable "username" {
  default = "james"
}
variable "password" {
  default = "password"
}
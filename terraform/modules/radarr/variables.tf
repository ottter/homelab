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
variable "plexdir_movies" {
  default = "/mnt/plex/movies"
  type    = string
}
variable "plexdir_root" {
  default     = "/mnt/plex"
  description = "Filepath on NFS share for Plex root location"
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
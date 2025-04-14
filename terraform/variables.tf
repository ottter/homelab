variable "kubeconfig" {}
variable "domain_root" {}
variable "node_ip" {}
variable "service_list" {}
variable "kubecost_token" {}
variable "discord_image" {}
variable "github_username" {}
variable "github_pat" {}
variable "plex_token" {}
variable "plex_path_config" {
  default = "/mnt/plex/config"
}
variable "plex_path_tv" {
  default = "/mnt/plex/tv"
}
variable "plex_path_movies" {
  default = "/mnt/plex/movies"
}
variable "transmission_user" {
  default = "admin"
}
variable "transmission_pass" {
  default = "password"
}
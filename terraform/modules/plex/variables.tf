variable "plex_token" {
  type      = string
  sensitive = true
}
variable "plex_path_config" {
  type = string
}
variable "plex_path_tv" {
  type = string
}
variable "plex_path_movies" {
  type = string
}
variable "plex_lb_ip" {
  type = string
}

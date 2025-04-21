variable "domain_root" {
  default = "local"
  type    = string
}
variable "domain_sub" {
  default = "homepage"
  type    = string
}
variable "apikey_sonarr" {
  default = ""
  type    = string
  sensitive = true
}
variable "apikey_radarr" {
  default = ""
  type    = string
  sensitive = true
}
variable "apikey_openweathermap" {
  default   = ""
  type      = string
  sensitive = true
}
variable "apikey_weatherapi" {
  default   = ""
  type      = string
  sensitive = true
}
variable "server_ip" {}
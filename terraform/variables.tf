variable "kubeconfig" {
  default     = "~/.kube/config"
  description = "Location of kube config file to access cluster"
}
variable "domain_root" {
  default     = "local"
  description = "Root domain name for the environment. (.local; homelab.local)"
}
variable "node_ip" {
  default     = ["192.168.0.144"]
  description = "A List of IP Addresses associated with the cluster"
  type        = list(any)
}
variable "kubecost_token" {
  description = "Kubecost token. A free trial one can be gotten from https://www.kubecost.com/install.html"
}
variable "discord_image" {
  description = "Name of Docker image to deploy"
  # Should in theory work with any Docker image but I am using it for a discord bot
}
variable "github_username" {
  description = "Github Username to access image on Github Container Registry"
}
variable "github_pat" {
  description = "Github PAT to access image on Github Container Registry"
}
variable "plex_token" {
  description = "Create a Plex account and get a token from https://www.plex.tv/claim/"
}
variable "plex_path_config" {
  default     = "/mnt/plex/config"
  description = "Filepath on NFS share for Plex config"
}
variable "plex_path_tv" {
  default     = "/mnt/plex/tv"
  description = "Filepath on NFS share for Plex tv"
}
variable "plex_path_movies" {
  default     = "/mnt/plex/movies"
  description = "Filepath on NFS share for Plex movies"
}
variable "transmission_user" {
  default     = "admin"
  description = "Basic Auth username to access Transmission. Can be disabled in values.yaml"
}
variable "transmission_pass" {
  default     = "password"
  description = "Basic Auth password to access Transmission. Can be disabled in values.yaml"
}
variable "enable_discord" {
  default     = false
  description = "Enable the Discord module"
  type        = bool
}
variable "enable_plex" {
  default     = false
  description = "Enable the Plex module"
  type        = bool
}
variable "enable_kubecost" {
  default     = false
  description = "Enable the Kubecost module"
  type        = bool
}
variable "enable_transmission" {
  default     = false
  description = "Enable the Transmission module"
  type        = bool
}
variable "enable_radarr" {
  default     = false
  description = "Enable the Radarr module"
  type        = bool
}
variable "enable_sonarr" {
  default     = false
  description = "Enable the Sonarr module"
  type        = bool
}
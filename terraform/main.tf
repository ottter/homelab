module "nginx" {
  source      = "./modules/nginx"
  domain_root = var.domain_root
  node_ip     = element(var.node_ip, 0)
}

module "kubecost" {
  source         = "./modules/kubecost"
  count          = contains(var.service_list, "kubecost") ? 1 : 0
  ca_cert_pem    = module.nginx.ca_cert_pem
  ca_priv_key    = module.nginx.ca_priv_key
  domain_root    = var.domain_root
  kubecost_token = var.kubecost_token
  node_ip        = element(var.node_ip, 0)
}

module "discord" {
  source        = "./modules/discord"
  count         = contains(var.service_list, "discord") ? 1 : 0
  discord_image = var.discord_image
  # discord_token   = var.discord_token
  github_username = var.github_username
  github_pat      = var.github_pat
}

module "plex" {
  source           = "./modules/plex"
  count            = contains(var.service_list, "plex") ? 1 : 0
  ca_cert_pem      = module.nginx.ca_cert_pem
  ca_priv_key      = module.nginx.ca_priv_key
  domain_root      = var.domain_root
  server_ip        = element(var.node_ip, 0)
  plex_token       = var.plex_token
  plex_path_config = var.plex_path_config
  plex_path_tv     = var.plex_path_tv
  plex_path_movies = var.plex_path_movies
}

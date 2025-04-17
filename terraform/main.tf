module "nginx" {
  source      = "./modules/nginx"
  domain_root = var.domain_root
  node_ip     = element(var.node_ip, 0)
}

module "kubecost" {
  source         = "./modules/kubecost"
  count          = var.enable_kubecost ? 1 : 0
  domain_root    = var.domain_root
  kubecost_token = var.kubecost_token
  node_ip        = element(var.node_ip, 0)
}

module "discord" {
  source          = "./modules/discord"
  count           = var.enable_discord ? 1 : 0
  discord_image   = var.discord_image
  github_username = var.github_username
  github_pat      = var.github_pat
}

module "homepage" {
  source           = "./modules/homepage"
  count            = var.enable_homepage ? 1 : 0
  domain_root      = var.domain_root
  server_ip        = element(var.node_ip, 0)
}

module "plex" {
  source           = "./modules/plex"
  count            = var.enable_plex ? 1 : 0
  domain_root      = var.domain_root
  server_ip        = element(var.node_ip, 0)
  plex_token       = var.plex_token
  plex_path_config = var.plex_path_config
  plex_path_tv     = var.plex_path_tv
  plex_path_movies = var.plex_path_movies
}

module "radarr" {
  source               = "./modules/radarr"
  count                = var.enable_radarr ? 1 : 0
  domain_root          = var.domain_root
  server_ip            = element(var.node_ip, 0)
  plexdir_movies       = "/mnt/plex/"
  transmission_enabled = var.enable_transmission
  transmission_user    = var.transmission_user
  transmission_pass    = var.transmission_pass
  depends_on           = [module.transmission]
}

module "sonarr" {
  source               = "./modules/sonarr"
  count                = var.enable_sonarr ? 1 : 0
  domain_root          = var.domain_root
  server_ip            = element(var.node_ip, 0)
  plexdir_tv           = var.plex_path_tv
  transmission_enabled = var.enable_transmission
  transmission_user    = var.transmission_user
  transmission_pass    = var.transmission_pass
  depends_on           = [module.transmission]
}

module "transmission" {
  source            = "./modules/transmission"
  count             = var.enable_transmission ? 1 : 0
  domain_root       = var.domain_root
  plexdir_downloads = var.plex_path_downloads
}

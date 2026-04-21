module "discord" {
  source          = "./modules/discord"
  count           = var.enable_discord ? 1 : 0
  discord_image   = var.discord_image
  github_username = var.github_username
  github_pat      = var.github_pat
}

module "homepage" {
  source                = "./modules/homepage"
  count                 = var.enable_homepage ? 1 : 0
  domain_root           = var.domain_root
  traefik_lb_ip         = var.traefik_lb_ip
  plex_lb_ip            = var.plex_lb_ip
  plex_token            = var.plex_token
  stock_watchlist       = var.stock_watchlist
  apikey_finnhub        = var.apikey_finnhub
  apikey_openweathermap = var.apikey_openweathermap
  apikey_weatherapi     = var.apikey_weatherapi
  apikey_radarr         = var.enable_radarr ? module.radarr[0].radarr_api_key : ""
  apikey_sonarr         = var.enable_sonarr ? module.sonarr[0].sonarr_api_key : ""
  transmission_user     = var.enable_transmission ? var.transmission_user : ""
  transmission_pass     = var.enable_transmission ? var.transmission_pass : ""
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
  plex_lb_ip       = var.plex_lb_ip
}

module "radarr" {
  source               = "./modules/radarr"
  count                = var.enable_radarr ? 1 : 0
  domain_root          = var.domain_root
  server_ip            = element(var.node_ip, 0)
  nfs_enabled          = var.nfs_enabled
  nfs_mount_point      = var.nfs_mount_point
  homepage_enabled     = var.enable_homepage
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
  nfs_enabled          = var.nfs_enabled
  nfs_mount_point      = var.nfs_mount_point
  homepage_enabled     = var.enable_homepage
  transmission_enabled = var.enable_transmission
  transmission_user    = var.transmission_user
  transmission_pass    = var.transmission_pass
  depends_on           = [module.transmission]
}

module "yamtrack" {
  source           = "./modules/yamtrack"
  count            = var.enable_yamtrack ? 1 : 0
  domain_root      = var.domain_root
  yamtrack_path_db = var.yamtrack_path_db
  homepage_enabled = var.enable_homepage
}

module "transmission" {
  source              = "./modules/transmission"
  count               = var.enable_transmission ? 1 : 0
  domain_root         = var.domain_root
  plexdir_downloads   = var.plex_path_downloads
  transmission_config = var.plex_path_config_transmission
  homepage_enabled    = var.enable_homepage
  username            = var.transmission_user
  password            = var.transmission_pass
}

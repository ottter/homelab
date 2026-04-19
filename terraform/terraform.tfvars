domain_root = "local"   # Must match domain_suffix in ansible/group_vars/all.yml
kubeconfig  = "~/.kube/config"

# IP layout — all addresses must be outside the router's DHCP range
# +-------------------+---------------------------+
# | node_ip           | 192.168.0.210             |  k3s node, dnsmasq
# | metallb_pool      | 192.168.0.220-192.168.0.230 |  MetalLB pool (keep outside DHCP)
# | traefik (derived) | first IP of metallb_pool  |  Traefik ingress controller
# | plex_lb_ip        | 192.168.0.221             |  Plex media server
# +-------------------+---------------------------+
node_ip      = ["192.168.0.210"]
metallb_pool = "192.168.0.220-192.168.0.230"

# Module: Discord
enable_discord  = false
github_username = "GITHUB_USERNAME"
github_pat      = "GITHUB_PAT"
discord_image   = "GITHUB_CONTAINER_REGISTRY_IMAGE"

# Module: Homepage
enable_homepage       = false
apikey_finnhub        = "APIKEY" # Optional: https://finnhub.io/
apikey_openweathermap = "APIKEY" # Optional: https://openweathermap.org/
apikey_weatherapi     = "APIKEY" # Optional: https://www.weatherapi.com/

stock_watchlist = ["SPY", "NVDA", "TSM", "MSFT", "AAPL"]

# Module: Plex
enable_plex         = false
plex_token          = "PLEX_TOKEN"             # https://www.plex.tv/claim/
plex_lb_ip          = "192.168.0.221"          # Must match plex_lb_ip in ansible/group_vars/all.yml; must be within metallb_pool
plex_path_downloads = "/mnt/plex/downloads"    # Must contain subdirectories 'complete' and 'incomplete'
plex_path_config    = "/mnt/plex/config"       # Plex config directory
plex_path_movies    = "/mnt/plex/media/movies" # Plex movies directory
plex_path_tv        = "/mnt/plex/media/tv"     # Plex TV directory

# Module: Radarr
enable_radarr = false

# Module: Sonarr
enable_sonarr = false

# Module: Transmission
enable_transmission = false
transmission_user   = "TRANSMISSION_USER"
transmission_pass   = "TRANSMISSION_PASS"

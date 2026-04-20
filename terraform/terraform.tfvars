domain_root = "local" # Must match domain_suffix in ansible/group_vars/all.yml
kubeconfig  = "~/.kube/config"

# IP layout — MetalLB and Traefik are managed by Ansible (ansible/group_vars/all.yml)
# These values must match what Ansible configured on the cluster.
#
# +-------------------+---------------------------+
# | node_ip           | 192.168.0.210             |  k3s node, dnsmasq
# | traefik_lb_ip     | 192.168.0.220             |  Traefik ingress — must match metallb_pool[0] in Ansible
# | plex_lb_ip        | 192.168.0.221             |  Plex media server — must be within metallb_pool
# +-------------------+---------------------------+
node_ip       = ["192.168.0.210"]
traefik_lb_ip = "192.168.0.220" # Must match traefik_lb_ip in ansible/group_vars/all.yml
plex_lb_ip    = "192.168.0.221" # Must match plex_lb_ip in ansible/group_vars/all.yml

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
plex_path_downloads = "/mnt/plex/downloads"    # Must contain subdirectories 'complete' and 'incomplete'
plex_path_config    = "/mnt/plex/config"       # Plex config directory
plex_path_movies    = "/mnt/plex/media/movies" # Plex movies directory
plex_path_tv        = "/mnt/plex/media/tv"     # Plex TV directory

# NFS — set nfs_enabled = true once external drive is attached and Ansible NFS role has run
nfs_enabled     = false
nfs_mount_point = "/mnt/plex"

# Module: Radarr
enable_radarr = false

# Module: Sonarr
enable_sonarr = false

# Module: Transmission
enable_transmission = false
transmission_user   = "TRANSMISSION_USER"
transmission_pass   = "TRANSMISSION_PASS"

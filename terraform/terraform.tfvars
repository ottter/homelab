domain_root = "local"
kubeconfig  = "~/.kube/config"

# List of IP addresses associated to Control and Worker nodes
node_ip = ["192.168.0.144"]

# Module: Discord
enable_discord  = false
github_username = "GITHUB_USERNAME"
github_pat      = "GITHUB_PAT"
discord_image   = "GITHUB_CONTAINER_REGISTRY_IMAGE"

# Module: Kubecost
enable_kubecost = false
kubecost_token  = "KUBECOST_TOKEN"

# Module: Plex
enable_plex         = false
plex_token          = "PLEX_TOKEN"             # https://www.plex.tv/claim/
plex_path_downloads = "/mnt/plex/downloads"    # Where *arr downloads files for temp holding
plex_path_config    = "/mnt/plex/config"       # Plex config direcotry
plex_path_movies    = "/mnt/plex/media/movies" # Plex movies directory
plex_path_tv        = "/mnt/plex/media/tv"     # Plex TV directory

# Module: Radarr
enable_radarr = false

# Module: Sonarr
enable_sonarr = false

# Module: Transmission
enable_transmission = false
transmission_user   = "admin"
transmission_pass   = "password"

domain_root = "local"
kubeconfig  = "~/.kube/config"

# List of IP addresses associated to Control and Worker nodes
node_ip = ["192.168.0.144"]

# Module: Discord
enable_discord  = false
github_username = "GITHUB_USERNAME"
github_pat      = "GITHUB_PAT"
discord_image   = "GITHUB_CONTAINER_REGISTRY_IMAGE"

# Module: Plex
enable_plex = false
plex_token  = "PLEX_TOKEN" # https://www.plex.tv/claim/

# Module: Kubecost
enable_kubecost = false
kubecost_token  = "KUBECOST_TOKEN"

# Module: Transmission
enable_transmission = false
transmission_user   = "admin"
transmission_pass   = "password"

# Module: Radarr
enable_radarr = false

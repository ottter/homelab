domain_root = "local"
kubeconfig  = "~/.kube/config"

service_list = [
  "kubecost",
  "discord",
  "plex",
  "transmission",
  "radarr"
]

discord_image = "registry/bot-image:latest"

plex_token = "TOKEN" # https://www.plex.tv/claim/

github_username = "USERNAME"
github_pat      = "PAT"

kubecost_token = "TOKEN"

# Transmission
transmission_user = "admin"
transmission_pass = "password"

# Radarr/Sonarr

# List of IP addresses associated to Control and Worker nodes
node_ip = ["192.168.0.144"]

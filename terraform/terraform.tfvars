domain_root = "local"
kubeconfig  = "~/.kube/config"

service_list = [
  "kubecost",
  "discord",
  "plex"
]

discord_image = "registry/bot-image:latest"

github_username = "USERNAME"
github_pat      = "PAT"

kubecost_token = "TOKEN"

plex_token = "TOKEN" # https://www.plex.tv/claim/

# List of IP addresses associated to Control and Worker nodes
node_ip = ["192.168.0.144"]

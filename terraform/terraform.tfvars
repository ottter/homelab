domain_root = "local"
kubeconfig  = "~/.kube/config"

service_list = [
  "kubecost",
  "discord"
]

discord_image = "registry/bot-image:latest"
# discord_token = "TOKEN"

github_username = "USERNAME"
github_pat      = "PAT"

kubecost_token = "TOKEN"

# List of IP addresses associated to Control and Worker nodes
node_ip = ["192.168.0.144"]

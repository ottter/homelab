domain_root    = "local"
kubeconfig     = "~/.kube/config"

service_list = [
  "kubecost"
]

# ## NGINX Config
cert_paths = {
  dod_certs = "../certs/dod_rootca.pem",
  bah_certs = "../certs/bah_rootca.crt",
}

kubecost_token = ""

# List of IP addresses associated to Control and Worker nodes
node_ip = ["192.168.114.131"]

# ## Bootstrap Config
# Control and Worker nodes should be created with the same username, password and root password
# If not, manual changes have to be done to ../playbooks/hosts after running Terraform
ansible_user = "james"
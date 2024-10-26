module "nginx" {
  source         = "./modules/nginx"
  domain_root    = var.domain_root
  node_ip        = element(var.node_ip, 0)
}

module "kubecost" {
  source         = "./modules/kubecost"
  count          = contains(var.service_list, "kubecost") ? 1 : 0
  ca_cert_pem    = module.nginx.ca_cert_pem
  ca_priv_key    = module.nginx.ca_priv_key
  domain_root    = var.domain_root
  kubecost_token = var.kubecost_token
  node_ip        = element(var.node_ip, 0)
}

module "nginx" {
  source         = "./modules/nginx"
  cert_paths     = var.cert_paths
  domain_root    = var.domain_root
  worker_node_ip = var.worker_node_ip
}

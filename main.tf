module "nginx" {
  source         = "./modules/nginx"
  domain_root    = var.domain_root
  worker_node_ip = var.worker_node_ip
}

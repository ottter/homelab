variable "metallb_pool" {
  description = "MetalLB IP address pool range (e.g. '192.168.0.220-192.168.0.230'). Traefik is assigned the first IP."
  type        = string
}

locals {
  traefik_lb_ip = split("-", var.metallb_pool)[0]
}

output "hosts_file" {
  description = "Fallback: paste into /etc/hosts if not using dnsmasq for DNS resolution"
  value       = <<-EOT
    # Traefik ingress services — point to MetalLB IP
    ${split("-", var.metallb_pool)[0]} homepage.${var.domain_root} radarr.${var.domain_root} sonarr.${var.domain_root} transmission.${var.domain_root}

    # Plex — own MetalLB IP, bypasses Traefik
    ${var.plex_lb_ip} plex.${var.domain_root}
  EOT
}

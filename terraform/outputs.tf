output "hosts_file" {
  description = "Fallback: paste into /etc/hosts if not using dnsmasq"
  value = join("\n", [
    "# Traefik ingress services -- point to MetalLB/Traefik IP",
    "${var.traefik_lb_ip} homepage.${var.domain_root} radarr.${var.domain_root} sonarr.${var.domain_root} transmission.${var.domain_root}",
    "",
    "# Plex -- own MetalLB IP, bypasses Traefik",
    "${var.plex_lb_ip} plex.${var.domain_root}",
  ])
}

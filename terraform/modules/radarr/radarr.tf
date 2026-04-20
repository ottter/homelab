resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = "radarr"
  }
}

# https://truecharts.org/charts/stable/radarr/
resource "helm_release" "radarr" {
  name      = "radarr"
  namespace = kubernetes_namespace_v1.ns.metadata[0].name

  repository = "oci://oci.trueforge.org/truecharts"
  chart      = "radarr"

  values = [
    templatefile("${path.module}/values-tmpl.yaml", {
      tls_secret       = "${kubernetes_namespace_v1.ns.metadata[0].name}-tls"
      full_path        = "${var.domain_sub}.${var.domain_root}"
      homepage_enabled = var.homepage_enabled
      nfs_enabled      = var.nfs_enabled
      nfs_mount_point  = var.nfs_mount_point
      server_ip        = var.server_ip
    })
  ]
}

resource "null_resource" "configure_radarr" {
  count = var.transmission_enabled ? 1 : 0

  provisioner "local-exec" {
    command     = "${path.module}/files/config.sh $NS $TUSER $TPASS $TNS 9091 $DOMAIN_ROOT"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      NS          = kubernetes_namespace_v1.ns.metadata[0].name
      TUSER       = var.transmission_user
      TPASS       = var.transmission_pass
      TNS         = var.transmission_ns
      DOMAIN_ROOT = var.domain_root
    }
  }

  depends_on = [helm_release.radarr]
}

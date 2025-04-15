resource "kubernetes_namespace" "ns" {
  metadata {
    labels = {
      istio-injection = "enabled"
    }
    name = "sonarr"
  }
}

# https://truecharts.org/charts/stable/sonarr/
resource "helm_release" "sonarr" {
  name      = "sonarr"
  namespace = kubernetes_namespace.ns.metadata[0].name

  repository = "oci://tccr.io/truecharts"
  chart      = "sonarr"

  values = [
    templatefile("${path.module}/values-tmpl.yaml", {
      tls_secret = kubernetes_secret.tls.metadata[0].name
      full_path  = "${var.domain_sub}.${var.domain_root}"
      plexdir_tv = "${var.plexdir_tv}"
      server_ip  = "${var.server_ip}"
    })
  ]
}

resource "null_resource" "configure_sonarr" {
  count = var.transmission_enabled ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      bash ${path.module}/files/config.sh ${kubernetes_namespace.ns.metadata[0].name} ${var.transmission_user} ${var.transmission_pass} ${var.transmission_ns}
    EOT
  }

  depends_on = [helm_release.sonarr]
}

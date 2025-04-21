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
      homepage_enabled    = var.homepage_enabled
      plexdir_tv = "${var.plexdir_tv}"
      server_ip  = "${var.server_ip}"
    })
  ]
}

resource "null_resource" "configure_sonarr" {
  count = var.transmission_enabled ? 1 : 0

  provisioner "local-exec" {
    command     = "${path.module}/files/config.sh $NS $TUSER $TPASS $TNS"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      NS    = kubernetes_namespace.ns.metadata[0].name
      TUSER = var.transmission_user
      TPASS = var.transmission_pass
      TNS   = var.transmission_ns
    }
  }


  depends_on = [helm_release.sonarr]
}

resource "tls_private_key" "service_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "service_cert" {
  private_key_pem = tls_private_key.service_key.private_key_pem

  validity_period_hours = 8760 # 1 year

  subject {
    common_name  = "kubecost.${var.domain_root}"
    organization = "HomeLab"
  }
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["kubecost.${var.domain_root}"]
}

resource "kubernetes_secret" "tls" {

  metadata {
    name      = "${kubernetes_namespace.ns.metadata[0].name}-tls"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }

  data = {
    "tls.crt" = tls_self_signed_cert.service_cert.cert_pem
    "tls.key" = tls_private_key.service_key.private_key_pem
  }

  type = "kubernetes.io/tls"
}
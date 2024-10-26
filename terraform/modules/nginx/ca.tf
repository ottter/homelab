# create a local CA to have individual services signed off that
# can optionally have everyone use the same cert, but not best practice
resource "tls_private_key" "ca_key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ca_cert" {
  is_ca_certificate = true

  private_key_pem       = tls_private_key.ca_key.private_key_pem
  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]

  subject {
    common_name  = "*.${var.domain_root}"
    organization = "Example"
  }

  dns_names = ["*.${var.domain_root}"]

}

resource "kubernetes_secret" "cacerts" {
  metadata {
    name      = "cacerts"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }

  data = {
    "cacerts.pem" = tls_self_signed_cert.ca_cert.cert_pem
  }
}
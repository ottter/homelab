resource "tls_private_key" "service_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "service_csr" {
  private_key_pem = tls_private_key.service_key.private_key_pem

  subject {
    common_name  = "${kubernetes_namespace.ns.metadata[0].name}.${var.domain_root}"
    organization = "Example"
  }

  dns_names    = ["${kubernetes_namespace.ns.metadata[0].name}.${var.domain_root}"]
  ip_addresses = ["127.0.0.1", var.node_ip]
}

resource "tls_locally_signed_cert" "service_cert" {
  cert_request_pem      = tls_cert_request.service_csr.cert_request_pem
  ca_cert_pem           = var.ca_cert_pem
  ca_private_key_pem    = var.ca_priv_key
  validity_period_hours = 8760
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "kubernetes_secret" "tls" {

  metadata {
    name      = "${kubernetes_namespace.ns.metadata[0].name}-tls"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }

  data = {
    "tls.crt" = tls_locally_signed_cert.service_cert.cert_pem
    "tls.key" = tls_private_key.service_key.private_key_pem
  }

  type = "kubernetes.io/tls"
}
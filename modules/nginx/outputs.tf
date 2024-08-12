output "ca_cert_pem" {
  value       = tls_self_signed_cert.ca_cert.cert_pem
  description = "CA cert pem"
  # sensitive = true
}

output "ca_priv_key" {
  value       = tls_private_key.ca_key.private_key_pem
  description = "CA private key"
  # sensitive = true
}
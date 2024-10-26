resource "kubernetes_namespace" "ns" {
  metadata {
    name = "nginx"
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  namespace  = kubernetes_namespace.ns.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  set {
    name  = "controller.extraArgs.enable-ssl-passthrough"
    value = true
  }

  # values = [
  #   templatefile("${path.module}/templates/values-tmpl.yaml", {
  #     certs_secret = kubernetes_secret.combined_certs.metadata[0].name
  #   })
  # ]
}

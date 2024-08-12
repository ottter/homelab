resource "kubernetes_namespace" "ns" {
  metadata {
    name = "nginx"
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = kubernetes_namespace.ns.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  values = "${path.module}/files/values-tmpl.yaml"
}
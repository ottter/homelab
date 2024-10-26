# kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090

resource "kubernetes_namespace" "ns" {
  metadata {
    labels = {
      istio-injection = "enabled"
    }
    name = "kubecost"
  }
}

resource "helm_release" "kubecost" {
  name       = "kubecost"
  chart      = "cost-analyzer"
  namespace  = kubernetes_namespace.ns.metadata[0].name
  repository = "https://kubecost.github.io/cost-analyzer/"

  values = [
    templatefile("${path.module}/values-tmpl.yaml", {
      tls_secret     = kubernetes_secret.tls.metadata[0].name
      kubecost_token = var.kubecost_token
      domain_root    = var.domain_root
    })
  ]
}
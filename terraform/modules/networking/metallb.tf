resource "kubernetes_namespace" "metallb" {
  metadata {
    name = "metallb-system"
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  namespace  = kubernetes_namespace.metallb.metadata[0].name
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"

  values = [
    file("${path.module}/metallb-values.yaml")
  ]
}

resource "kubernetes_manifest" "ip_address_pool" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = "homelab-pool"
      namespace = kubernetes_namespace.metallb.metadata[0].name
    }
    spec = {
      addresses = [var.metallb_pool]
    }
  }

  depends_on = [helm_release.metallb]
}

resource "kubernetes_manifest" "l2_advertisement" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"
    metadata = {
      name      = "homelab-l2"
      namespace = kubernetes_namespace.metallb.metadata[0].name
    }
    spec = {
      ipAddressPools = ["homelab-pool"]
    }
  }

  depends_on = [kubernetes_manifest.ip_address_pool]
}

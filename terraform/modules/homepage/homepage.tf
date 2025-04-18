locals {
  bookmarks_yaml  = file("${path.module}/configs/bookmarks-tmpl.yaml")
  kubernetes_yaml = file("${path.module}/configs/kubernetes-tmpl.yaml")
  services_yaml = templatefile("${path.module}/configs/services-tmpl.yaml", {
    domain_root = var.domain_root
  })
  settings_yaml = templatefile("${path.module}/configs/settings-tmpl.yaml", {
    openweathermap = var.apikey_openweathermap
    weatherapi     = var.apikey_weatherapi
  })
  widgets_yaml = file("${path.module}/configs/widgets-tmpl.yaml")
}

resource "kubernetes_namespace" "ns" {
  metadata {
    labels = {
      istio-injection = "enabled"
    }
    name = "homepage"
  }
}

# https://truecharts.org/charts/stable/homepage/
resource "helm_release" "homepage" {
  name      = "homepage"
  namespace = kubernetes_namespace.ns.metadata[0].name

  repository = "oci://tccr.io/truecharts"
  chart      = "homepage"

  values = [
    templatefile("${path.module}/values-tmpl.yaml", {
      tls_secret = kubernetes_secret.tls.metadata[0].name
      full_path  = "${var.domain_sub}.${var.domain_root}"
    })
  ]
}

resource "kubernetes_config_map" "homepage_config" {
  metadata {
    name      = "homepage-config"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }

  data = {
    "bookmarks.yaml"  = local.bookmarks_yaml
    "custom.js"       = ""
    "custom.css"      = ""
    "kubernetes.yaml" = local.kubernetes_yaml
    "services.yaml"   = local.services_yaml
    "settings.yaml"   = local.settings_yaml
    "widgets.yaml"    = local.widgets_yaml
  }
}
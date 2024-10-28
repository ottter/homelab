locals {
  media_storage_gb = var.media_storage - 30
}

resource "kubernetes_persistent_volume" "plex_media_pv" {
  metadata {
    name = "plex-media-pv"
  }

  spec {
    capacity = {
      storage = "${local.media_storage_gb}Gi"
    }
    persistent_volume_source {
      nfs {
        path   = "${var.media_mount}/media"
        server = var.server_ip
      }
    }
    access_modes = ["ReadWriteMany"]
    storage_class_name = "local-path"
    persistent_volume_reclaim_policy = "Retain"
  }
}

resource "kubernetes_persistent_volume_claim" "plex_media_pvc" {
  metadata {
    name      = "plex-media-pvc"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "${local.media_storage_gb}Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.plex_media_pv.metadata.0.name
  }
}

resource "kubernetes_persistent_volume" "plex_config_pv" {
  metadata {
    name = "plex-config-pv"
  }

  spec {
    capacity = {
      storage = "10Gi"
    }

    persistent_volume_source {
      nfs {
        path   = "${var.media_mount}/config"
        server = var.server_ip
      }
    }

    access_modes = ["ReadWriteOnce"]
    storage_class_name = "local-path"
    persistent_volume_reclaim_policy = "Retain"
  }
}

resource "kubernetes_persistent_volume_claim" "plex_config_pvc" {
  metadata {
    name      = "plex-config-pvc"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.plex_config_pv.metadata.0.name
  }
}

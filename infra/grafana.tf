
resource "kubernetes_secret_v1" "grafana" {
  metadata {
    name      = "grafana-secret"
    namespace = kubernetes_namespace_v1.apps.metadata[0].name
  }

  data = {
    GF_SECURITY_ADMIN_USER     = var.grafana_admin_username
    GF_SECURITY_ADMIN_PASSWORD = var.grafana_admin_password
  }
}

resource "kubernetes_deployment_v1" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace_v1.apps.metadata[0].name
    labels = {
      app = "grafana"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "grafana"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana"
        }
      }

      spec {
        container {
          name  = "grafana"
          image = "grafana/grafana:latest"

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.grafana.metadata[0].name
            }
          }

          port {
            container_port = 3000
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment_v1.keycloak]
}

resource "kubernetes_service_v1" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace_v1.apps.metadata[0].name
  }

  spec {
    selector = {
      app = "grafana"
    }

    type = "ClusterIP"

    port {
      name        = "http"
      port        = var.grafana_port
      target_port = 3000
    }
  }
}
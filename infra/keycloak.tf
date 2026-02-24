
resource "kubernetes_secret_v1" "keycloak" {
  metadata {
    name      = "keycloak-secret"
    namespace = kubernetes_namespace_v1.apps.metadata[0].name
  }

  data = {
    KC_DB                       = var.postgres_db
    KC_DB_URL                   = "jdbc:postgresql://${kubernetes_service_v1.postgres.metadata[0].name}/${var.postgres_db}"
    KC_DB_USERNAME              = var.postgres_user
    KC_DB_PASSWORD              = var.postgres_password
    KC_BOOTSTRAP_ADMIN_USERNAME = var.keycloak_admin_username
    KC_BOOTSTRAP_ADMIN_PASSWORD = var.keycloak_admin_password
  }
}

resource "kubernetes_deployment_v1" "keycloak" {
  metadata {
    name      = "keycloak"
    namespace = kubernetes_namespace_v1.apps.metadata[0].name
    labels = {
      app = "keycloak"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "keycloak"
      }
    }

    template {
      metadata {
        labels = {
          app = "keycloak"
        }
      }

      spec {
        container {
          name  = "keycloak"
          image = "quay.io/keycloak/keycloak:26.5.4"
          args  = ["start-dev"]

          env {
            name  = "KC_HEALTH_ENABLED"
            value = "true"
          }
          env {
            name  = "KC_DB"
            value = "postgres"
          }
          env_from {
            secret_ref {
              name = kubernetes_secret_v1.keycloak.metadata[0].name
            }
          }

          port {
            name           = "http"
            container_port = 8080
          }
          port {
            name           = "management"
            container_port = 9000
          }

          readiness_probe {
            http_get {
              path = "/health/ready"
              port = 9000
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            failure_threshold     = 10
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment_v1.postgres]
}

resource "kubernetes_service_v1" "keycloak" {
  metadata {
    name      = "keycloak"
    namespace = kubernetes_namespace_v1.apps.metadata[0].name
  }

  spec {
    selector = {
      app = "keycloak"
    }

    type = "ClusterIP"

    port {
      name        = "http"
      port        = var.keycloak_port
      target_port = 8080
    }
  }
}
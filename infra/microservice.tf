
resource "kubernetes_config_map_v1" "microservice_script" {
  metadata {
    name      = "microservice-script"
    namespace = kubernetes_namespace_v1.apps.metadata[0].name
  }

  data = {
    "microservice.py" = file("${path.module}/microservice.py")
  }
}

resource "kubernetes_secret_v1" "microservice" {
  metadata {
    name      = "microservice-secret"
    namespace = kubernetes_namespace_v1.apps.metadata[0].name
  }

  data = {
    KEYCLOAK_URL   = "http://${kubernetes_service_v1.keycloak.metadata[0].name}.${kubernetes_namespace_v1.apps.metadata[0].name}.svc.cluster.local:8080"
    KEYCLOAK_REALM = var.keycloak_realm
    CLIENT_ID      = var.microservice_client_id
    CLIENT_SA_ROLE = var.microservice_client_sa_role
  }
}

resource "kubernetes_deployment_v1" "microservice" {
  metadata {
    name      = "microservice"
    namespace = kubernetes_namespace_v1.apps.metadata[0].name
    labels = {
      app = "microservice"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "microservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "microservice"
        }
      }
      spec {
        container {
          name    = "microservice"
          image   = "python:3.12-slim"
          command = ["sh", "-c", "pip install --quiet fastapi PyJWT[crypto] uvicorn && python /app/microservice.py"]
          env {
            name  = "PYTHONUNBUFFERED"
            value = "1"
          }

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.microservice.metadata[0].name
            }
          }

          port {
            container_port = 9000
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 9000
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            failure_threshold     = 10
          }

          volume_mount {
            name       = "script"
            mount_path = "/app"
            read_only  = true
          }
        }

        volume {
          name = "script"
          config_map {
            name = kubernetes_config_map_v1.microservice_script.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment_v1.keycloak]
}

resource "kubernetes_service_v1" "microservice" {
  metadata {
    name      = "microservice"
    namespace = kubernetes_namespace_v1.apps.metadata[0].name
  }

  spec {
    selector = {
      app = "microservice"
    }

    type = "ClusterIP"

    port {
      name        = "http"
      port        = var.microservice_port
      target_port = 9000
    }
  }
}
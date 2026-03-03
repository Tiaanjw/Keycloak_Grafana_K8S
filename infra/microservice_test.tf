
resource "kubernetes_config_map_v1" "microservice_test_script" {
  metadata {
    name      = "microservice-test-script"
    namespace = kubernetes_namespace_v1.apps.metadata[0].name
  }

  data = {
    "microservice_test.py" = file("${path.module}/microservice_test.py")
  }
}

resource "kubernetes_secret_v1" "microservice_test" {
  metadata {
    name      = "microservice-test-secret"
    namespace = kubernetes_namespace_v1.apps.metadata[0].name
  }

  data = {
    KEYCLOAK_URL   = "http://${kubernetes_service_v1.keycloak.metadata[0].name}.${kubernetes_namespace_v1.apps.metadata[0].name}.svc.cluster.local:8080"
    API_URL        = "http://${kubernetes_service_v1.microservice.metadata[0].name}.${kubernetes_namespace_v1.apps.metadata[0].name}.svc.cluster.local:9000"
    KEYCLOAK_REALM = var.keycloak_realm
    CLIENT_ID      = var.microservice_client_id
    CLIENT_SECRET  = var.microservice_client_secret
  }
}

resource "kubernetes_cron_job_v1" "microservice_test" {
  metadata {
    name      = "microservice-test"
    namespace = kubernetes_namespace_v1.apps.metadata[0].name
  }

  spec {
    schedule                      = "*/5 * * * *"
    concurrency_policy            = "Forbid"
    failed_jobs_history_limit     = 3
    successful_jobs_history_limit = 3

    job_template {
      metadata {
        labels = {
          app = "microservice-test"
        }
      }

      spec {
        template {
          metadata {
            labels = {
              app = "microservice-test"
            }
          }

          spec {
            restart_policy = "OnFailure"

            container {
              name    = "microservice-test"
              image   = "python:3.12-slim"
              command = ["sh", "-c", "pip install --quiet requests && python /app/microservice_test.py"]

              env {
                name  = "PYTHONUNBUFFERED"
                value = "1"
              }

              env_from {
                secret_ref {
                  name = kubernetes_secret_v1.microservice_test.metadata[0].name
                }
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
                name = kubernetes_config_map_v1.microservice_test_script.metadata[0].name
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment_v1.keycloak]
}
output "grafana_url" {
  value = "http://localhost:${var.grafana_port}"
}

output "keycloak_url" {
  value = "http://localhost:${var.keycloak_port}"
}

output "microservice_url" {
  value = "http://localhost:${var.keycloak_port}"
}
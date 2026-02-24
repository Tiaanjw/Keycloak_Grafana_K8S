terraform {
  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "5.7.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "4.25.0"
    }
  }
}

provider "keycloak" {
  client_id     = "admin-cli"
  username      = var.keycloak_admin_username
  password      = var.keycloak_admin_password
  url           = "http://${var.keycloak_external_host}:${var.keycloak_external_port}"
  initial_login = false
}

provider "grafana" {
  url  = "http://${var.grafana_external_host}:${var.grafana_external_port}"
  auth = "${var.grafana_admin_username}:${var.grafana_admin_password}"
}
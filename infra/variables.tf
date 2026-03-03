variable "kube_config_path" {
  description = "A kube config"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_config_context" {
  description = "A context to use"
  type        = string
  default     = ""
}

variable "postgres_db" {
  description = "Postgres database name"
  type        = string
}

variable "postgres_user" {
  description = "Postgres username"
  type        = string
}

variable "postgres_password" {
  description = "Postgres password"
  type        = string
  sensitive   = true
}

variable "keycloak_realm" {
  description = "Keycloak realm name"
  type        = string
}

variable "keycloak_admin_username" {
  description = "Keycloak admin username"
  type        = string
}

variable "keycloak_admin_password" {
  description = "Keycloak admin password"
  type        = string
  sensitive   = true
}

variable "keycloak_port" {
  description = "Port to expose Keycloak on localhost"
  type        = number
  default     = 8080
}

variable "grafana_admin_username" {
  description = "Grafana built-in admin username"
  type        = string
}

variable "grafana_admin_password" {
  description = "Grafana built-in admin password"
  type        = string
  sensitive   = true
}

variable "grafana_port" {
  description = "Port to expose Grafana on localhost"
  type        = number
  default     = 3000
}

variable "microservice_client_id" {
  description = "Client ID for the microservice"
  type        = string
  sensitive   = true
}

variable "microservice_client_secret" {
  description = "Client secret for the microservice"
  type        = string
  sensitive   = true
}

variable "microservice_client_sa_role" {
  description = "Client SA role for the microservice"
  type        = string
  sensitive   = true
}

variable "microservice_port" {
  description = "Port to expose microservice on localhost"
  type        = number
  default     = 9000
}
variable "keycloak_internal_host" {
  description = "Host of keycloak internal in kubernetes"
  type        = string
}

variable "keycloak_external_host" {
  description = "Host for keycloak externally"
  type        = string
}

variable "keycloak_realm" {
  description = "Keycloak realm name"
  type        = string
}

variable "keycloak_admin_username" {
  description = "Keycloak admin username"
  type        = string
  default     = "admin"
}

variable "keycloak_admin_password" {
  description = "Keycloak admin password"
  type        = string
  sensitive   = true
  default     = "admin"
}

variable "keycloak_external_port" {
  description = "Port of Keycloak exposed on localhost"
  type        = number
  default     = 8080
}

variable "keycloak_internal_port" {
  description = "Port of Keycloak exposed on cluster"
  type        = number
  default     = 8080
}

variable "grafana_kc_client_id" {
  description = "Client id shared between Keycloak and Grafana"
  type        = string
  sensitive   = true
}

variable "grafana_kc_client_secret" {
  description = "Client secret shared between Keycloak and Grafana"
  type        = string
  sensitive   = true
}

variable "grafana_external_host" {
  description = "Grafana host"
  type        = string
}

variable "grafana_admin_username" {
  description = "Grafana built-in admin username"
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  description = "Grafana built-in admin password"
  type        = string
  sensitive   = true
  default     = "admin"
}

variable "grafana_external_port" {
  description = "Port of Grafana exposed on localhost"
  type        = number
}

variable "microservice_kc_client_id" {
  description = "Client id shared between Keycloak and the microservice"
  type        = string
  sensitive   = true
}

variable "microservice_kc_client_secret" {
  description = "Client secret shared between Keycloak and the microservice"
  type        = string
  sensitive   = true
}

variable "grafana_kc_roles" {
  description = "Roles to be created in Keycloak for Grafana"
  type        = list(string)
}

variable "users_list" {
  description = "User list and attributes"
  type = list(object({
    username   = string
    first_name = string
    last_name  = string
    password   = string
    email      = string
    roles      = list(string)
  }))
}
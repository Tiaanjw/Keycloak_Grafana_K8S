keycloak_internal_host  = "keycloak"
keycloak_external_host  = "localhost"
keycloak_external_port  = 8080
keycloak_internal_port  = 8080
keycloak_admin_username = "admin"
keycloak_admin_password = "admin"
keycloak_realm          = "app-realm"

grafana_external_host    = "localhost"
grafana_admin_username   = "admin"
grafana_admin_password   = "admin"
grafana_kc_client_id     = "grafana"
grafana_kc_client_secret = "grafana_kc_1234"
grafana_external_port    = 3000

microservice_kc_client_id     = "microservice"
microservice_kc_client_secret = "kc_ms_1234"


grafana_kc_roles = ["admin", "editor", "viewer"]
users_list = [
  { "username" : "anna", "first_name" : "Anna", "last_name" : "Nas", "password" : "anna123", "email" : "anna.nas@example.com", "roles" : ["admin"] },
  { "username" : "wil", "first_name" : "Wil", "last_name" : "Helmes", "password" : "wil123", "email" : "wil.helmes@example.com", "roles" : ["editor"] },
  { "username" : "bennie", "first_name" : "Bennie", "last_name" : "Thuis", "password" : "bennie123", "email" : "bennie.thuis@example.com", "roles" : ["viewer"] },
]
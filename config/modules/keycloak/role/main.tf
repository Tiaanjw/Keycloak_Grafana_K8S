resource "keycloak_role" "admin" {
  realm_id = var.realm_id
  name     = var.role_name
}
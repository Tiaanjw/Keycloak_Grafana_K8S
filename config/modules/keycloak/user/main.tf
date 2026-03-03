resource "keycloak_user" "user" {
  realm_id       = var.realm_id
  username       = var.username
  first_name     = var.first_name
  last_name      = var.last_name
  email          = var.email
  enabled        = true
  email_verified = true

  initial_password {
    value     = var.initial_password
    temporary = false
  }
}

data "keycloak_role" "roles" {
  count     = length(var.roles)
  realm_id  = var.realm_id
  client_id = var.client_id
  name      = var.roles[count.index]
}

resource "keycloak_user_roles" "roles" {
  realm_id = var.realm_id
  user_id  = keycloak_user.user.id
  role_ids = data.keycloak_role.roles[*].id
}
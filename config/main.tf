locals {
  # This looks fancy but just makes the this:
  # "contains(roles[*], 'admin') && 'Admin' || contains(roles[*], 'editor') && 'Editor' || contains(roles[*], 'viewer') && 'Viewer' || 'Viewer'"
  grafana_role_attribute_path = "${join(
    " || ",
    [
      for role in var.grafana_kc_roles :
      "contains(roles[*], '${role}') && '${title(role)}'"
    ]
  )} || 'Viewer'"
}

resource "keycloak_realm" "app" {
  realm   = var.keycloak_realm
  enabled = true
}

#####
# Grafana Keycloak setup
#####

resource "keycloak_openid_client" "grafana" {
  realm_id              = keycloak_realm.app.id
  client_id             = var.grafana_kc_client_id
  name                  = "grafana"
  enabled               = true
  access_type           = "CONFIDENTIAL"
  client_secret         = var.grafana_kc_client_secret
  standard_flow_enabled = true
  valid_redirect_uris   = ["http://${var.grafana_external_host}:${var.grafana_external_port}/*"]
  web_origins           = ["http://${var.grafana_external_host}:${var.grafana_external_port}"]
}

resource "keycloak_openid_user_client_role_protocol_mapper" "grafana_role_mapper" {
  realm_id                    = keycloak_realm.app.id
  client_id                   = keycloak_openid_client.grafana.id
  client_id_for_role_mappings = keycloak_openid_client.grafana.client_id
  name                        = "grafana-client-role-mapper"
  claim_name                  = "roles"
  multivalued                 = true
  add_to_id_token             = true
  add_to_access_token         = true
  add_to_userinfo             = true
}

resource "keycloak_role" "grafana_role" {
  for_each  = toset(var.grafana_kc_roles)
  realm_id  = keycloak_realm.app.id
  client_id = keycloak_openid_client.grafana.id
  name      = each.value
}

module "keycloak_user" {
  source = "./modules/keycloak/user"
  providers = {
    keycloak = keycloak
  }
  count = length(var.users_list)

  realm_id         = keycloak_realm.app.id
  client_id        = keycloak_openid_client.grafana.id
  username         = var.users_list[count.index].username
  first_name       = var.users_list[count.index].first_name
  last_name        = var.users_list[count.index].last_name
  email            = var.users_list[count.index].email
  initial_password = var.users_list[count.index].password

  roles = var.users_list[count.index].roles

  depends_on = [keycloak_role.grafana_role]
}

resource "grafana_sso_settings" "generic_sso_settings" {
  provider_name = "generic_oauth"
  oauth2_settings {
    name                  = "Keycloak"
    auth_url              = "http://${var.keycloak_external_host}:${var.keycloak_external_port}/realms/app-realm/protocol/openid-connect/auth"
    token_url             = "http://${var.keycloak_internal_host}:${var.keycloak_internal_port}/realms/app-realm/protocol/openid-connect/token"
    api_url               = "http://${var.keycloak_internal_host}:${var.keycloak_internal_port}/realms/app-realm/protocol/openid-connect/userinfo"
    signout_redirect_url  = "http://${var.keycloak_external_host}:${var.keycloak_external_port}/realms/app-realm/protocol/openid-connect/logout"
    client_id             = var.grafana_kc_client_id
    client_secret         = var.grafana_kc_client_secret
    allow_sign_up         = true
    auto_login            = false
    scopes                = "openid profile email roles"
    role_attribute_path   = local.grafana_role_attribute_path
    role_attribute_strict = false
  }
}

#####
# Microservice Keycloak setup
#####
resource "keycloak_openid_client" "microservice" {
  realm_id                 = keycloak_realm.app.id
  client_id                = var.microservice_kc_client_id
  name                     = "microservice"
  enabled                  = true
  access_type              = "CONFIDENTIAL"
  client_secret            = var.microservice_kc_client_secret
  service_accounts_enabled = true
  standard_flow_enabled    = false
}

resource "keycloak_role" "microservice_role" {
  realm_id  = keycloak_realm.app.id
  client_id = keycloak_openid_client.microservice.id
  name      = var.microservice_client_sa_role
}

resource "keycloak_openid_client_service_account_role" "client_service_account_role" {
  realm_id                = keycloak_realm.app.id
  service_account_user_id = keycloak_openid_client.microservice.service_account_user_id
  client_id               = keycloak_openid_client.microservice.id
  role                    = keycloak_role.microservice_role.name
}

resource "keycloak_openid_audience_protocol_mapper" "microservice_audience_mapper" {
  realm_id                 = keycloak_realm.app.id
  client_id                = keycloak_openid_client.microservice.id
  name                     = "audience-mapper"
  included_client_audience = keycloak_openid_client.microservice.client_id
  add_to_access_token      = true
}
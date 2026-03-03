variable "realm_id" {
  description = "Realm ID"
  type        = string
}

variable "client_id" {
  description = "OIDC client ID"
  type        = string
}

variable "username" {
  description = "Username of a user"
  type        = string
}

variable "first_name" {
  description = "Firstname of a user"
  type        = string
}

variable "last_name" {
  description = "Lastname of a user"
  type        = string
}

variable "email" {
  description = "Email of a user"
  type        = string
}

variable "initial_password" {
  description = "Initial password of a user"
  type        = string
  sensitive   = true
}

variable "roles" {
  description = "List of roles for a user"
  type        = list(string)
}
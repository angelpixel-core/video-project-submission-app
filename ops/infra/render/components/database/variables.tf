variable "name" {
  description = "Render PostgreSQL database name."
  type        = string
}

variable "environment" {
  description = "Render environment name."
  type        = string
}

variable "database_name" {
  description = "Database name created inside Postgres."
  type        = string
}

variable "database_user" {
  description = "Database user created for the service."
  type        = string
}

variable "plan" {
  description = "Render PostgreSQL plan."
  type        = string
}

variable "postgres_version" {
  description = "PostgreSQL major version."
  type        = string
}

variable "region" {
  description = "Render region for the database."
  type        = string
}

variable "ip_allow_list" {
  description = "Allow list entries for the database."
  type = list(object({
    cidr_block  = string
    description = string
  }))
  default = []
}

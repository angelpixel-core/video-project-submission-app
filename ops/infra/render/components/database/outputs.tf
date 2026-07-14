output "name" {
  value = render_postgres.this.name
}

output "environment" {
  value = var.environment
}

output "database_name" {
  value = var.database_name
}

output "database_user" {
  value = var.database_user
}

output "plan" {
  value = var.plan
}

output "postgres_version" {
  value = var.postgres_version
}

output "region" {
  value = var.region
}

output "id" {
  value = render_postgres.this.id
}

output "connection_info" {
  value     = render_postgres.this.connection_info
  sensitive = true
}

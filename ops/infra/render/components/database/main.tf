resource "render_postgres" "this" {
  name                      = var.name
  plan                      = var.plan
  region                    = var.region
  version                   = var.postgres_version
  database_name             = var.database_name
  database_user             = var.database_user
  disk_size_gb              = 1
  high_availability_enabled = false
  ip_allow_list             = var.ip_allow_list
}

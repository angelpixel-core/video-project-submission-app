output "name" {
  value = render_web_service.this.name
}

output "branch" {
  value = var.branch
}

output "health_check_path" {
  value = var.health_check_path
}

output "instance_type" {
  value = var.instance_type
}

output "region" {
  value = var.region
}

output "id" {
  value = render_web_service.this.id
}

output "url" {
  value = render_web_service.this.url
}

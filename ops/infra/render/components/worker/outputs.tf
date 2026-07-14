output "name" {
  value = render_background_worker.this.name
}

output "environment" {
  value = var.environment
}

output "branch" {
  value = var.branch
}

output "instance_type" {
  value = var.instance_type
}

output "region" {
  value = var.region
}

output "id" {
  value = render_background_worker.this.id
}

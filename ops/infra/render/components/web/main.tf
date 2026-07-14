resource "render_web_service" "this" {
  name              = var.name
  plan              = var.instance_type
  region            = var.region
  health_check_path = var.health_check_path
  start_command     = var.start_command

  runtime_source = {
    native_runtime = {
      runtime       = "ruby"
      repo_url      = "https://github.com/angelpixel-core/video-project-submission-app"
      branch        = var.branch
      build_command = var.build_command
    }
  }

  env_vars = {
    RAILS_ENV = {
      value = var.environment
    }
  }
}

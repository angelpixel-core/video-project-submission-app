module "web" {
  source              = "../../components/web"
  name                = "video-project-submission-app"
  branch              = "main"
  build_command       = "bundle install && npm ci && bundle exec vite build"
  start_command       = "bundle exec puma -C config/puma.rb"
  health_check_path   = "/up"
  instance_type       = "free"
  region              = "oregon"
  environment_id      = var.environment_id
  auto_deploy         = true
  auto_deploy_trigger = "checksPass"
  env_vars = {
    DATABASE_URL = {
      value = module.database.connection_info.internal_connection_string
    }
    RAILS_LOG_TO_STDOUT = {
      value = "true"
    }
    RAILS_MASTER_KEY = {
      value = var.rails_master_key
    }
  }
}

module "database" {
  source           = "../../components/database"
  name             = "video-project-submission-app-db"
  environment      = "prod"
  database_name    = "video_project_submission_app_prod"
  database_user    = "video_project_submission_app_prod"
  plan             = "free"
  postgres_version = "18"
  region           = "oregon"
  ip_allow_list = [
    {
      cidr_block  = "0.0.0.0/0"
      description = "everywhere"
    }
  ]
}

module "worker" {
  count = var.enable_worker ? 1 : 0

  source        = "../../components/worker"
  name          = "video-project-submission-app-worker"
  environment   = "prod"
  branch        = "main"
  start_command = "bundle exec rails solid_queue:start"
  instance_type = "free"
  region        = "oregon"
}

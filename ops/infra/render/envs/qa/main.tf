module "web" {
  source              = "../../components/web"
  name                = "video-project-submission-app-qa"
  branch              = "development"
  build_command       = "bundle install && npm ci && bundle exec vite build"
  start_command       = "bundle exec puma -C config/puma.rb"
  health_check_path   = "/up"
  instance_type       = "free"
  region              = "oregon"
  environment_id      = var.adopted_environment_id
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
  name             = "video-project-submission-app-qa-db"
  environment      = "qa"
  database_name    = "video_project_submission_app_qa"
  database_user    = "video_project_submission_app_qa"
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

module "web" {
  source            = "../../components/web"
  name              = "video-project-submission-app-qa"
  environment       = "qa"
  branch            = "development"
  build_command     = "bundle install && npm ci && bundle exec vite build"
  start_command     = "bundle exec puma -C config/puma.rb"
  health_check_path = "/up"
  instance_type     = "free"
  region            = "oregon"
}

module "postgres" {
  source           = "../../components/postgres"
  name             = "video-project-submission-app-qa-db"
  environment      = "qa"
  database_name    = "video_project_submission_app_qa_db"
  database_user    = "video_project_submission_app_qa"
  plan             = "free"
  postgres_version = "18"
  region           = "oregon"
}

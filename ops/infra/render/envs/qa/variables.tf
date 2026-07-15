variable "owner_id" {
  description = "Render owner identifier."
  type        = string
}

variable "adopted_web_service_id" {
  description = "QA Render web service ID to adopt."
  type        = string
}

variable "adopted_database_id" {
  description = "QA Render database ID to adopt."
  type        = string
}

variable "adopted_environment_id" {
  description = "QA Render environment ID to adopt."
  type        = string
}

variable "rails_master_key" {
  description = "QA Rails master key."
  type        = string
  sensitive   = true
}

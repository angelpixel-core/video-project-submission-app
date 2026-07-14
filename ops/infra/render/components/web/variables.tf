variable "name" {
  description = "Render web service name."
  type        = string
}

variable "branch" {
  description = "Git branch used for deploys."
  type        = string
}

variable "build_command" {
  description = "Build command for the web service."
  type        = string
}

variable "start_command" {
  description = "Start command for the web service."
  type        = string
}

variable "health_check_path" {
  description = "Health check path exposed by the web service."
  type        = string
  default     = "/up"
}

variable "instance_type" {
  description = "Render instance type for the web service."
  type        = string
}

variable "region" {
  description = "Render region for the web service."
  type        = string
}

variable "environment_id" {
  description = "Render environment identifier for the web service."
  type        = string
}

variable "auto_deploy" {
  description = "Whether Render should auto-deploy this service."
  type        = bool
}

variable "auto_deploy_trigger" {
  description = "Automatic deploy trigger for the web service."
  type        = string
}

variable "env_vars" {
  description = "Environment variables for the web service."
  type = map(object({
    value          = optional(string)
    generate_value = optional(bool)
  }))
}

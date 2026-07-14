variable "rails_master_key" {
  description = "Staging Rails master key."
  type        = string
  sensitive   = true
}

variable "environment_id" {
  description = "Staging Render environment identifier."
  type        = string
}

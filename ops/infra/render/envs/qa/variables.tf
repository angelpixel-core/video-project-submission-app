variable "owner_id" {
  description = "Render owner identifier."
  type        = string
}

variable "rails_master_key" {
  description = "QA Rails master key."
  type        = string
  sensitive   = true
}

variable "owner_id" {
  description = "Render owner identifier."
  type        = string
}

variable "rails_master_key" {
  description = "Production Rails master key."
  type        = string
  sensitive   = true
}

variable "environment_id" {
  description = "Production Render environment identifier."
  type        = string
}

variable "enable_worker" {
  description = "Whether the production worker should be enabled."
  type        = bool
  default     = false
}

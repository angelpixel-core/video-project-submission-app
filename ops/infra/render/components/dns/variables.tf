variable "hostname" {
  description = "Public hostname for the environment."
  type        = string
}

variable "environment" {
  description = "Render environment name."
  type        = string
}

variable "service_name" {
  description = "Render service associated with the hostname."
  type        = string
}

variable "tls_enabled" {
  description = "Whether TLS should be enabled for the hostname."
  type        = bool
  default     = true
}

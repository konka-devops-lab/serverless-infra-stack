variable "environment" {
  description = "The environment for the resources (e.g., dev, staging, prod)"
  type        = string
}
variable "application_name" {
  description = "The name of the application"
  type        = string
}
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "aliases" {
  description = "List of custom domain aliases"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  
}

variable "zone_id" {}

variable "record_name" {}

variable "allowed_origins" {}
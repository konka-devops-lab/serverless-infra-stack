variable "environment" {
  description = "The environment for which the ACM certificate is being created (e.g., dev, staging, prod)."
  type        = string
}
variable "project_name" {
  description = "The name of the project for which the ACM certificate is being created."
  type        = string
}
variable "common_tags" {
  description = "Common tags to be applied to all resources."
  type        = map(string)
  default     = {}
}
variable "domain_name" {
  description = "The domain name for the ACM certificate."
  type        = string
}
variable "validation_method" {
  description = "The validation method for Certificate"
  type        = string
}
variable "zone_id" {
  description = "The Route 53 zone ID for DNS validation."
  type        = string
  default     = null
}

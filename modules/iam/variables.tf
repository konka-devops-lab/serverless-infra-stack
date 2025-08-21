variable "environment" {
  description = "The environment for the IAM resources (e.g., dev, staging, prod)"
  type        = string
}
variable "project_name" {
  description = "The name of the project for which the IAM resources are created"
  type        = string
}
variable "common_tags" {
  description = "Common tags to be applied to all IAM resources"
  type        = map(string)
  default     = {}
}
variable "role_name" {
  description = "The name of the IAM role to be created"
  type        = string
}
variable "policy_name" {
  description = "The name of the IAM policy to be created"
  type        = string
}
variable "policy_file" {
  description = "The path to the IAM policy file in JSON format"
  type        = string
}
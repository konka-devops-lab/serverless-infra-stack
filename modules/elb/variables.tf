variable "environment" {
  description = "The environment for which the ELB is being created (e.g., dev, staging, prod)."
  type        = string
}
variable "project" {
  description = "The project name for which the ELB is being created."
  type        = string
}
variable "lb_name" {
  description = "The name of the load balancer."
  type        = string
}
variable "choose_internal_external" {
  description = "Choose whether the ELB is internal or external. Set to true for internal, false for external."
  type        = bool
}
variable "load_balancer_type" {
  description = "The type of load balancer to create (e.g., application, network)."
  type        = string
}

variable "security_groups" {
  description = "A list of security group IDs to associate with the ELB."
  type        = list(string)
}
variable "subnets" {
  description = "A list of subnet IDs where the ELB will be deployed."
  type        = list(string)
}
variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ELB."
  type        = bool
  default     = false
}
variable "common_tags" {
  description = "Common tags to apply to all resources created by this module."
  type        = map(string)
  default     = {}
}

# Target Group Variables
variable "tg_port" {
  description = "The port on which the target group will listen."
  type        = number
}

variable "enable_zonal_shift" {
  description = "Enable zonal shift for the ELB."
  type        = bool
}
variable "vpc_id" {
  description = "The VPC ID where the ELB and target group will be created."
  type        = string
}

variable "health_check_path" {
  description = "The path for the health check of the target group."
  type        = string
}
variable "enable_http" {
  description = "Enable HTTP listener"
  type        = bool
}
variable "enable_https" {
  description = "Enable HTTPS listener"
  type        = bool
}
variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener"
  type        = string
  default     = ""
}
variable "zone_id" {
  description = "The Route 53 zone ID for DNS records."
  type        = string
}
variable "record_name" {
  description = "The name of the DNS record to create for the ELB."
  type        = string
}
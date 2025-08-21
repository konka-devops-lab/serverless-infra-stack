variable "environment" {
  description = "Environment for the infrastructure (e.g., dev, staging, prod)"
  type        = string
}
variable "application_name" {
  description = "Name of the application"
  type        = string
}
variable "sg_name" {
  description = "Name of the security group"
  type        = string
}
variable "sg_description" {
  description = "Description of the security group"
  type        = string
}
variable "vpc_id" {
  description = "ID of the VPC to which the security group will be attached"
  type        = string
}
variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}
variable "ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

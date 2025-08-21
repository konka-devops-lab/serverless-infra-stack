variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "environment" {
  description = "Environment for the infrastructure (e.g., dev, staging, prod)"
  type        = string
}
variable "application_name" {
  description = "Name of the application"
  type        = string
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR block for the public subnets"
  type        = list(string)
}

variable "availability_zone" {
  description = "Availability zone for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR block for the public subnets"
  type        = list(string)
}

variable "db_subnet_cidr_blocks" {
  description = "CIDR block for the public subnets"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
}
variable "enable_vpc_flow_logs_cw" {
  description = "Enable VPC Flow Logs"
  type        = bool
}


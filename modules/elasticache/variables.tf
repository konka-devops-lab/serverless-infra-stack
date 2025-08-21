variable "environment" {
  description = "The environment for the Elastic Cache cluster"
  type        = string
}
variable "project_name" {
  description = "The name of the project for the Elastic Cache cluster"
  type        = string
}

variable "engine" {
  description = "The engine for the Elastic Cache cluster"
  type        = string
}
variable "major_engine_version" {
  description = "The major engine version for the Elastic Cache cluster"
  type        = string
}
variable "security_group_ids" {
  description = "The security group IDs for the Elastic Cache cluster"
  type        = list(string)
}
variable "subnet_ids" {
  description = "The subnet IDs for the Elastic Cache cluster"
  type        = list(string)
}
variable "common_tags" {
  description = "Common tags to apply to the Elastic Cache cluster"
  type        = map(string)
  default     = {}
}

variable "zone_id" {
  description = "The ID of the Route 53 hosted zone"
  type        = string
}

variable "elasticache_record_name" {
  description = "The name of the Route 53 record for the RDS instance"
  type        = string
}

variable "record_type" {
  description = "The type of the Route 53 record"
  type        = string
}

variable "ttl" {
  description = "The TTL for the Route 53 record"
  type        = number
}

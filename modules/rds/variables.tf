variable "allocated_storage" {
  description = "The amount of storage (in gigabytes) to be initially allocated for the database instance."
  type        = number
}
variable "engine" {
  description = "The name of the database engine to be used for this instance."
  type        = string
}
variable "engine_version" {
  description = "The version number of the database engine to use."
  type        = string
}
variable "instance_class" {
  description = "The compute and memory capacity of the DB instance, for example db.m4.large."
  type        = string
}
variable "username" {
  description = "The name of master user for the client DB instance."
  type        = string
}
variable "password" {
  description = "The password for the master database user."
  type        = string
}
variable "db_subnet_group_name" {
  description = "The DB subnet group to associate with this DB instance."
  type        = string
}
variable "vpc_security_group_ids" {
  description = "A list of EC2 VPC security groups to associate with this DB instance."
  type        = list(string)
  default     = []
}
variable "publicly_accessible" {
  description = "Specifies whether the DB instance is publicly accessible."
  type        = bool
}
variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted."
  type        = bool
}
variable "environment" {
  description = "The environment to use for the instance"
  type        = string
}
variable "project" {
  description = "The project to use for the instance"
  type        = string
}
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(any)
}
variable "storage_type" {
  description = "The storage type to use for the database instance"
  type        = string
}
variable "zone_id" {
  description = "The ID of the Route 53 hosted zone"
  type        = string
}
variable "rds_record_name" {
  description = "The name of the Route 53 record"
  type        = string
}
variable "record_type" {
  description = "The type of the Route 53 record"
  type        = string
}
variable "ttl" {
  description = "The TTL of the Route 53 record"
  type        = number
}

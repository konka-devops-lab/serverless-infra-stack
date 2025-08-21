output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.private_subnets[*].id
}

output "db_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.db_subnets[*].id
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = aws_db_subnet_group.default.name
}
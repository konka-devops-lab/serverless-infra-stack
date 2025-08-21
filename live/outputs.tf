########################### ACM Certificates For Backend Load Balancer ###########################
output "backend_acm_arn" {
  value       = module.backend_acm.certificate_arn
  description = "ARN of the ACM certificate for the backend load balancer"
}
########################### ACM Certificates For Frotnend #######################################
output "frontend_acm_arn" {
  value       = module.cloudfront_acm.certificate_arn
  description = "ARN of the ACM certificate for the cloudfront"
}

########################## ECS Task Role ARN  ###################################################
output "ecs_task_role_arn" {
  value       = module.ecs_role.role_arn
  description = "ARN of the ECS task role"
}

########################## VPC Outputs #########################################################
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}
output "db_subnet_ids" {
  description = "List of database subnet IDs"
  value       = module.vpc.db_subnet_ids
}
output "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = module.vpc.db_subnet_group_name
}

########################## Security Groups Outputs ##############################################
output "bastion_sg_id" {
  description = "The ID of the bastion security group"
  value       = module.bastion_sg.sg_id
}
output "backend_sg_id" {
  description = "The ID of the backend security group"
  value       = module.backend_sg.sg_id
}
output "elasticache_sg_id" {
  description = "The ID of the elasticache security group"
  value       = module.elasticache_sg.sg_id
}
output "rds_sg_id" {
  description = "The ID of the rds security group"
  value       = module.rds_sg.sg_id
}
output "alb_sg_id" {
  description = "The ID of the alb security group"
  value       = module.alb_sg.sg_id
}
########################## RDS Outputs ##########################################################
output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = module.rds.endpoint
}
########################### ElastiCache Outputs ################################################
output "elastic_cache_endpoint" {
  description = "The endpoint of the Elastic Cache cluster"
  value       = module.elasticache.endpoint
}
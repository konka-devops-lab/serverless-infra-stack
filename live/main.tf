########################### Data Block############################################################
data "aws_ssm_parameter" "rds_username" {
  name = "/example/rds/username"
}
data "aws_ssm_parameter" "rds_password" {
  name = "/example/rds/password"
}
########################### ACM Certificates For Backend Load Balancer ###########################
module "backend_acm" {
  source            = "../modules/acm"
  environment       = var.common_vars["environment"]
  project_name      = var.common_vars["application_name"]
  common_tags       = var.common_vars["common_tags"]
  domain_name       = var.lb_acm["domain_name"]
  validation_method = var.lb_acm["validation_method"]
  zone_id           = var.common_vars["zone_id"]
}
########################### ACM Certificates For CloudFront ######################################
module "cloudfront_acm" {
  source            = "../modules/acm"
  environment       = var.common_vars["environment"]
  project_name      = var.common_vars["application_name"]
  common_tags       = var.common_vars["common_tags"]
  domain_name       = var.cf_acm["domain_name"]
  validation_method = var.cf_acm["validation_method"]
  zone_id           = var.common_vars["zone_id"]
}

####################################### ECS IAM Roles ###########################################
module "ecs_role" {
  source       = "../modules/iam"
  environment  = var.common_vars["environment"]
  project_name = var.common_vars["application_name"]
  common_tags  = var.common_vars["common_tags"]
  role_name    = var.ecs_role["role_name"]
  policy_name  = var.ecs_role["policy_name"]
  policy_file  = "${path.module}/../env/${var.common_vars["environment"]}/policies/ecs-task.json"
}

####################################### VPC ######################################################
module "vpc" {
  source                     = "../modules/vpc"
  environment                = var.common_vars["environment"]
  application_name           = var.common_vars["application_name"]
  common_tags                = var.common_vars["common_tags"]
  vpc_cidr_block             = var.vpc["vpc_cidr_block"]
  availability_zone          = var.vpc["availability_zone"]
  public_subnet_cidr_blocks  = var.vpc["public_subnet_cidr_blocks"]
  private_subnet_cidr_blocks = var.vpc["private_subnet_cidr_blocks"]
  db_subnet_cidr_blocks      = var.vpc["db_subnet_cidr_blocks"]
  enable_nat_gateway         = var.vpc["enable_nat_gateway"]
  enable_vpc_flow_logs_cw    = var.vpc["enable_vpc_flow_logs_cw"]
}

########################## RDS #####################################################################
# module "rds" {
#   source                 = "../modules/rds"
#   username               = data.aws_ssm_parameter.rds_username.value
#   password               = data.aws_ssm_parameter.rds_password.value
#   db_subnet_group_name   = module.vpc.db_subnet_group_name
#   vpc_security_group_ids = [module.rds_sg.sg_id]
#   environment            = var.common_vars["environment"]
#   project                = var.common_vars["application_name"]
#   common_tags            = var.common_vars["common_tags"]
#   zone_id                = var.common_vars["zone_id"]
#   allocated_storage      = var.rds["allocated_storage"]
#   engine                 = var.rds["engine"]
#   engine_version         = var.rds["engine_version"]
#   instance_class         = var.rds["instance_class"]
#   publicly_accessible    = var.rds["publicly_accessible"]
#   skip_final_snapshot    = var.rds["skip_final_snapshot"]
#   storage_type           = var.rds["storage_type"]
#   rds_record_name        = var.rds["rds_record_name"]
#   record_type            = var.rds["record_type"]
#   ttl                    = var.rds["ttl"]
# }
############################ Common Variables ##############################################################
common_vars = {
  environment      = "dev"
  application_name = "carvo"
  region = "us-east-1"
  common_tags = {
    Project     = "carvo"
    Environment = "development"
    terraform   = "true"
    Owner       = "konka"
  }
  zone_id = "Z011675617HENPLWZ1EJC"
}

########################### ACM Certificates For Backend Load Balancer & CloudFront #######################
lb_acm = {
  domain_name       = "dev-ecs.konkas.tech"
  validation_method = "DNS"
}

cf_acm = {
  domain_name       = "dev-carvo.konkas.tech"
  validation_method = "DNS"
}

############################ ECS Task Role ###############################################################
ecs_role = {
  role_name   = "ecs-task-role"
  policy_name = "ecs-task-policy"
}
############################ VPC #########################################################################
vpc = {
  vpc_cidr_block             = "10.1.0.0/16"
  availability_zone          = ["us-east-1a", "us-east-1b"]
  public_subnet_cidr_blocks  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidr_blocks = ["10.1.11.0/24", "10.1.12.0/24"]
  db_subnet_cidr_blocks      = ["10.1.21.0/24", "10.1.22.0/24"]
  enable_nat_gateway         = false
  enable_vpc_flow_logs_cw    = false
}

########################### SG Configuration #############################################################
module "bastion_sg" {
  source           = "../modules/sg"
  environment      = var.common_vars["environment"]
  application_name = var.common_vars["application_name"]
  common_tags      = var.common_vars["common_tags"]
  vpc_id           = module.vpc.vpc_id
  sg_name          = var.sg["bastion_sg_name"]
  sg_description   = var.sg["bastion_sg_description"]
}
module "backend_sg" {
  source           = "../modules/sg"
  environment      = var.common_vars["environment"]
  application_name = var.common_vars["application_name"]
  common_tags      = var.common_vars["common_tags"]
  vpc_id           = module.vpc.vpc_id
  sg_name          = var.sg["backend_sg_name"]
  sg_description   = var.sg["backend_sg_description"]
}
module "elasticache_sg" {
  source           = "../modules/sg"
  environment      = var.common_vars["environment"]
  application_name = var.common_vars["application_name"]
  common_tags      = var.common_vars["common_tags"]
  vpc_id           = module.vpc.vpc_id
  sg_name          = var.sg["elasticache_sg_name"]
  sg_description   = var.sg["elasticache_sg_description"]
}
module "rds_sg" {
  source           = "../modules/sg"
  environment      = var.common_vars["environment"]
  application_name = var.common_vars["application_name"]
  common_tags      = var.common_vars["common_tags"]
  vpc_id           = module.vpc.vpc_id
  sg_name          = var.sg["rds_sg_name"]
  sg_description   = var.sg["rds_sg_description"]
}module "alb_sg" {
  source           = "../modules/sg"
  environment      = var.common_vars["environment"]
  application_name = var.common_vars["application_name"]
  common_tags      = var.common_vars["common_tags"]
  vpc_id           = module.vpc.vpc_id
  sg_name          = var.sg["alb_sg_name"]
  sg_description   = var.sg["elasticache_sg_description"]
}
############################## RDS #######################################################################
# rds = {
#   allocated_storage   = "20"
#   engine              = "mysql"
#   engine_version      = "8.0"
#   instance_class      = "db.t3.micro"
#   publicly_accessible = false
#   skip_final_snapshot = true
#   storage_type        = "gp3"
#   rds_record_name     = "dev-ecs"
#   record_type         = "CNAME"
#   ttl                 = "60"
# }

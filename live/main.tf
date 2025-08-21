########################### Data Block############################################################
data "aws_ssm_parameter" "rds_username" {
  name = "/example/rds/username"
}
data "aws_ssm_parameter" "rds_password" {
  name = "/example/rds/password"
}
data "aws_ssm_parameter" "ec2_key" {
  name            = "/expense/ec2/siva"
  with_decryption = true
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
########################### ACM Certificates For Backend Load Balancer ###########################
module "backend_acm" {
  source            = "../modules/acm"
  environment       = var.common_vars["environment"]
  project_name      = var.common_vars["application_name"]
  common_tags       = var.common_vars["common_tags"]
  domain_name       = var.acm["lb_domain_name"]
  validation_method = var.acm["validation_method"]
  zone_id           = var.common_vars["zone_id"]
}
########################### ACM Certificates For CloudFront ######################################
module "cloudfront_acm" {
  source            = "../modules/acm"
  environment       = var.common_vars["environment"]
  project_name      = var.common_vars["application_name"]
  common_tags       = var.common_vars["common_tags"]
  domain_name       = var.acm["cf_domain_name"]
  validation_method = var.acm["validation_method"]
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
}
module "alb_sg" {
  source           = "../modules/sg"
  environment      = var.common_vars["environment"]
  application_name = var.common_vars["application_name"]
  common_tags      = var.common_vars["common_tags"]
  vpc_id           = module.vpc.vpc_id
  sg_name          = var.sg["alb_sg_name"]
  sg_description   = var.sg["elasticache_sg_description"]
}
resource "aws_security_group_rule" "ssh_bastion" {
  description       = "Allow SSH access from anywhere"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion_sg.sg_id
}
resource "aws_security_group_rule" "bastion_rds" {
  description              = "Allow 3306 access from bastion"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id        = module.rds_sg.sg_id
}
resource "aws_security_group_rule" "backend_rds" {
  description              = "Allow 3306 access from backend"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.backend_sg.sg_id
  security_group_id        = module.rds_sg.sg_id
}
resource "aws_security_group_rule" "bastion_elasticache" {
  description              = "Allow 6379 access from bastion"
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id        = module.elasticache_sg.sg_id
}
resource "aws_security_group_rule" "backend_elasticache" {
  description              = "Allow 6379 access from backend"
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = module.backend_sg.sg_id
  security_group_id        = module.elasticache_sg.sg_id
}
resource "aws_security_group_rule" "bastion_backend" {
  description              = "Allow 8080 access from bastion"
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id        = module.backend_sg.sg_id
}
resource "aws_security_group_rule" "alb_backend" {
  description              = "Allow 8080 access from alb"
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.alb_sg.sg_id
  security_group_id        = module.backend_sg.sg_id
}
resource "aws_security_group_rule" "http_alb" {
  description       = "Allow http from internet to alb"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.alb_sg.sg_id
}
resource "aws_security_group_rule" "https_alb" {
  description       = "Allow https from internet to alb"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.alb_sg.sg_id
}
########################## RDS #####################################################################
module "rds" {
  source                 = "../modules/rds"
  username               = data.aws_ssm_parameter.rds_username.value
  password               = data.aws_ssm_parameter.rds_password.value
  db_subnet_group_name   = module.vpc.db_subnet_group_name
  vpc_security_group_ids = [module.rds_sg.sg_id]
  environment            = var.common_vars["environment"]
  project                = var.common_vars["application_name"]
  common_tags            = var.common_vars["common_tags"]
  zone_id                = var.common_vars["zone_id"]
  allocated_storage      = var.rds["allocated_storage"]
  engine                 = var.rds["engine"]
  engine_version         = var.rds["engine_version"]
  instance_class         = var.rds["instance_class"]
  publicly_accessible    = var.rds["publicly_accessible"]
  skip_final_snapshot    = var.rds["skip_final_snapshot"]
  storage_type           = var.rds["storage_type"]
  rds_record_name        = var.rds["rds_record_name"]
  record_type            = var.rds["record_type"]
  ttl                    = var.rds["ttl"]
}
########################### Elasticache ##########################################################
module "elasticache" {
  source                  = "../modules/elasticache"
  environment             = var.common_vars["environment"]
  project_name            = var.common_vars["application_name"]
  common_tags             = var.common_vars["common_tags"]
  zone_id                 = var.common_vars["zone_id"]
  security_group_ids      = [module.elasticache_sg.sg_id]
  subnet_ids              = module.vpc.db_subnet_ids
  engine                  = var.elasticache["engine"]
  major_engine_version    = var.elasticache["major_engine_version"]
  elasticache_record_name = var.elasticache["elasticache_record_name"]
  record_type             = var.elasticache["record_type"]
  ttl                     = var.elasticache["ttl"]
}
########################## Bastion Host ##########################################################
module "bastion" {
  source = "../modules/ec2"

  environment  = var.common_vars["environment"]
  project_name = var.common_vars["application_name"]
  common_tags  = var.common_vars["common_tags"]

  ami             = data.aws_ami.amazon_linux.id
  security_groups = [module.bastion_sg.sg_id]
  subnet_id       = module.vpc.public_subnet_ids[0]
  private_key     = data.aws_ssm_parameter.ec2_key.value

  instance_name                  = var.bastion["instance_name"]
  instance_type                  = var.bastion["instance_type"]
  monitoring                     = var.bastion["monitoring"]
  use_null_resource_for_userdata = var.bastion["use_null_resource_for_userdata"]
  remote_exec_user               = var.bastion["remote_exec_user"]
  key_name                       = var.bastion["key_name"]
  user_data                      = file("${path.module}/../env/${var.common_vars["environment"]}/scripts/bastion.sh")
}
########################## Backend ALB ##########################################################
module "external-alb" {
  source                     = "../modules/elb"
  environment                = var.common_vars["environment"]
  project                    = var.common_vars["application_name"]
  common_tags                = var.common_vars["common_tags"]
  zone_id                    = var.common_vars["zone_id"]
  security_groups            = [module.alb_sg.sg_id]
  subnets                    = module.vpc.public_subnet_ids
  vpc_id                     = module.vpc.vpc_id
  lb_name                    = var.alb["lb_name"]
  enable_deletion_protection = var.alb["enable_deletion_protection"]
  choose_internal_external   = var.alb["choose_internal_external"]
  load_balancer_type         = var.alb["load_balancer_type"]
  enable_zonal_shift         = var.alb["enable_zonal_shift"]
  tg_port                    = var.alb["tg_port"]
  health_check_path          = var.alb["health_check_path"]
  enable_http                = var.alb["enable_http"]
  enable_https               = var.alb["enable_https"]
  certificate_arn            = module.backend_acm.certificate_arn
  record_name                = var.alb["record_name"]
}
########################### S3 & CloudFront ##########################################################
module "s3-cloudfront" {
  source              = "../modules/s3-cloudfront"
  environment         = var.common_vars["environment"]
  application_name    = var.common_vars["application_name"]
  common_tags         = var.common_vars["common_tags"]
  zone_id             = var.common_vars["zone_id"]
  record_name         = var.s3-cf["record_name"]
  allowed_origins     = var.s3-cf["allowed_origins"]
  aliases             = var.s3-cf["aliases"]
  acm_certificate_arn = module.cloudfront_acm.certificate_arn
}
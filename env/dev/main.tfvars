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
acm = {
  lb_domain_name       = "dev-ecs.konkas.tech"
  cf_domain_name       = "dev-carvo.konkas.tech"
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

############################ Security Groups ###########################################################
sg = {
  bastion_sg_name        = "bastion-sg"
  bastion_sg_description = "Security group for bastion host"
  backend_sg_name        = "backend-sg"
  backend_sg_description = "Security group for backend services"
  elasticache_sg_name    = "elasticache-sg"
  elasticache_sg_description = "Security group for Elasticache"
  rds_sg_name            = "rds-sg"
  rds_sg_description     = "Security group for RDS"
  alb_sg_name            = "alb-sg"
  alb_sg_description     = "Security group for Application Load Balancer"
}
############################## RDS #######################################################################
rds = {
  allocated_storage   = "20"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  publicly_accessible = false
  skip_final_snapshot = true
  storage_type        = "gp3"
  rds_record_name     = "dev-rds"
  record_type         = "CNAME"
  ttl                 = "60"
}
############################## ElastiCache ###############################################################
elasticache = {
  engine                  = "valkey"
  major_engine_version    = "8"
  zone_id                 = "Z011675617HENPLWZ1EJC"
  elasticache_record_name = "dev-elasticache"
  record_type             = "CNAME"
  ttl                     = "60"
}
############################## Bastion Host ##############################################################
bastion = {
  instance_name                  = "bastion"
  instance_type                  = "t3.micro"
  key_name                       = "siva"
  monitoring                     = false
  use_null_resource_for_userdata = true
  remote_exec_user               = "ec2-user"
  iam_instance_profile           = ""
}
############################# Backend ALB ################################################################
alb = {
  lb_name                    = "backend"
  enable_deletion_protection = false
  choose_internal_external   = false
  enable_zonal_shift         = false
  load_balancer_type         = "application"
  tg_port                    = 8080
  health_check_path          = "/health"
  enable_http                = false
  enable_https               = true
  record_name                = "dev-ecs.konkas.tech"
}
############################ CF & S3 #####################################################################
s3-cf = {
  record_name = "dev-carvo.konkas.tech"
  allowed_origins = ["https://dev-ecs.konkas.tech"]
  aliases = ["dev-carvo.konkas.tech"]
}
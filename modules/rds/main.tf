locals {
  name = "${var.environment}-${var.project}"
}
resource "aws_db_instance" "default" {
  allocated_storage      = var.allocated_storage
  storage_type           = var.storage_type
  identifier             = local.name
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  username               = var.username
  password               = var.password
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible    = var.publicly_accessible
  skip_final_snapshot    = var.skip_final_snapshot
  tags = merge(
    {
      Name = local.name
    },
    var.common_tags
  )
}
resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = var.rds_record_name
  type    = var.record_type
  ttl     = var.ttl
  records = [aws_db_instance.default.address]
}

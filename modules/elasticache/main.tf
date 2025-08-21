locals {
  name = "${var.environment}-${var.project_name}"
}
resource "aws_elasticache_serverless_cache" "example" {
  engine               = var.engine
  name                 = local.name
  description          = "Elastic Cache cluster for Valkey"
  major_engine_version = var.major_engine_version
  security_group_ids   = var.security_group_ids
  subnet_ids           = var.subnet_ids
  tags = merge(
    var.common_tags,
    {
      Name = local.name
    }
  )
}
resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = var.elasticache_record_name
  type    = var.record_type
  ttl     = var.ttl
  records = [for address in aws_elasticache_serverless_cache.example.endpoint : address.address]
}




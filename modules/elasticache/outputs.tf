output "endpoint" {
  description = "The endpoint of the Elastic Cache cluster"
  value       = [for ep in aws_elasticache_serverless_cache.example.endpoint : ep.address]
}

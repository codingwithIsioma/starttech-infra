output "redis_host" {
  description = "The Redis endpoint"
  value       = aws_elasticache_cluster.redis-cluster.cache_nodes[0].address
}

output "redis_port" {
  description = "The Redis port"
  value       = aws_elasticache_cluster.redis-cluster.port
}
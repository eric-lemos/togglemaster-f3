output "subnet_group_name" {
  value = aws_elasticache_subnet_group.this.name
}

output "cluster_ids" {
  value = { for k, c in aws_elasticache_cluster.this : k => c.cluster_id }
}

output "cluster_endpoints" {
  value = { for k, c in aws_elasticache_cluster.this : k => c.cache_nodes[0].address }
}

output "cluster_ports" {
  value = { for k, c in aws_elasticache_cluster.this : k => c.port }
}

output "cluster_arns" {
  value = { for k, c in aws_elasticache_cluster.this : k => c.arn }
}

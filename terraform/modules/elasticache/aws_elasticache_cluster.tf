resource "aws_elasticache_cluster" "this" {
  for_each = var.elasticache.clusters

  cluster_id           = coalesce(each.value.name, each.key)
  engine               = each.value.engine
  engine_version       = each.value.engine_version
  node_type            = each.value.node_type
  num_cache_nodes      = each.value.num_cache_nodes
  port                 = each.value.port
  parameter_group_name = each.value.parameter_group_name

  subnet_group_name = aws_elasticache_subnet_group.this.name

  security_group_ids = concat(
    each.value.security_group_ids,
    [for n in each.value.security_group_names : data.aws_security_group.by_name[n].id]
  )

  apply_immediately = each.value.apply_immediately

  tags = merge(var.elasticache.tags, each.value.tags, {
    Name = coalesce(each.value.name, each.key)
  })
}

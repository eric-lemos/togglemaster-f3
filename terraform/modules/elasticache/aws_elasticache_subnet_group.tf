resource "aws_elasticache_subnet_group" "this" {
  name = var.elasticache.subnet_group.name

  subnet_ids = concat(
    var.elasticache.subnet_group.subnet_ids,
    [for n in var.elasticache.subnet_group.subnet_names : data.aws_subnet.by_name[n].id]
  )

  tags = merge(var.elasticache.tags, {
    Name = var.elasticache.subnet_group.name
  })
}

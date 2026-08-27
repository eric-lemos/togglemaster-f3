resource "aws_security_group" "this" {
  for_each = var.security_groups.groups

  vpc_id      = var.security_groups.vpc_id != null ? var.security_groups.vpc_id : data.aws_vpc.by_name[0].id
  name        = coalesce(each.value.name, each.key)
  description = each.value.description

  tags = merge(var.security_groups.tags, each.value.tags, {
    Name = coalesce(each.value.name, each.key)
  })
}

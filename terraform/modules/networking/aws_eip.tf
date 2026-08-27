resource "aws_eip" "nat" {
  for_each = var.networking.natgw
  domain   = "vpc"
  tags = merge(var.networking.vpc.tags, each.value.eip_tags, {
    Name = coalesce(each.value.name, each.key)
  })
}

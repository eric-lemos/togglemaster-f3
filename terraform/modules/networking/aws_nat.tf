resource "aws_nat_gateway" "this" {
  for_each      = var.networking.natgw
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.this[{ for sk, s in var.networking.subnet : coalesce(s.name, sk) => sk }[each.value.subnet_name]].id

  tags = merge(var.networking.vpc.tags, each.value.tags, {
    Name = coalesce(each.value.name, each.key)
  })

  depends_on = [aws_internet_gateway.this]
}

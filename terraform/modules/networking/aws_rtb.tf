resource "aws_route_table" "this" {
  for_each = var.networking.rtb

  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = each.value.routes
    content {
      cidr_block = route.value.cidr_block
      gateway_id = route.value.gateway_name == var.networking.igw.name ? aws_internet_gateway.this[0].id : null
      nat_gateway_id = route.value.nat_gateway_name != null ? aws_nat_gateway.this[
        { for nk, n in var.networking.natgw : coalesce(n.name, nk) => nk }[route.value.nat_gateway_name]
      ].id : null
    }
  }

  tags = merge(var.networking.vpc.tags, each.value.tags, {
    Name = coalesce(each.value.name, each.key)
  })
}

resource "aws_route_table_association" "this" {
  for_each = {
    for pair in flatten([
      for rt_key, rt in var.networking.rtb : [
        for sn in rt.subnet_names : {
          key        = "${rt_key}-${sn}"
          rt_key     = rt_key
          subnet_key = { for sk, s in var.networking.subnet : coalesce(s.name, sk) => sk }[sn]
        }
      ]
    ]) : pair.key => pair
  }

  subnet_id      = aws_subnet.this[each.value.subnet_key].id
  route_table_id = aws_route_table.this[each.value.rt_key].id
}

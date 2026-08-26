resource "aws_route_table" "this" {
  for_each = var.networking.rtb

  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = each.value.routes
    content {
      cidr_block     = route.value.cidr_block
      gateway_id     = route.value.gateway_key == "igw" ? aws_internet_gateway.this[0].id : null
      nat_gateway_id = route.value.nat_gateway_key != null ? aws_nat_gateway.this[route.value.nat_gateway_key].id : null
    }
  }

  tags = merge({
    ManagedBy   = "Terraform"
    Project     = var.shared_configs.project_name
    Environment = var.shared_configs.environment
    }, var.networking.vpc.tags, each.value.tags, {
    Name = "${var.shared_configs.project_name}-rtb-${each.key}"
  })
}

resource "aws_route_table_association" "this" {
  for_each = {
    for pair in flatten([
      for rt_key, rt in var.networking.rtb : [
        for sk in rt.subnet_keys : { key = "${rt_key}-${sk}", rt_key = rt_key, subnet_key = sk }
      ]
    ]) : pair.key => pair
  }

  subnet_id      = aws_subnet.this[each.value.subnet_key].id
  route_table_id = aws_route_table.this[each.value.rt_key].id
}

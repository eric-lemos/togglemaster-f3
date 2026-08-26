resource "aws_nat_gateway" "this" {
  for_each      = var.networking.natgw
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.this[each.value.subnet_key].id

  tags = merge({
    ManagedBy   = "Terraform"
    Project     = var.shared_configs.project_name
    Environment = var.shared_configs.environment
    }, var.networking.vpc.tags, each.value.tags, {
    Name = "${var.shared_configs.project_name}-nat-${each.key}"
  })

  depends_on = [aws_internet_gateway.this]
}

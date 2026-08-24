resource "aws_eip" "nat" {
  for_each = var.networking.natgw
  domain   = "vpc"
  tags = merge({ ManagedBy = "Terraform" }, var.networking.vpc.tags, each.value.eip_tags, {
    Name = "${var.networking.vpc.name}-nat-${each.key}"
  })
}

resource "aws_internet_gateway" "this" {
  count  = var.networking.igw.enabled ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags = merge(var.networking.vpc.tags, var.networking.igw.tags, {
    Name = var.networking.igw.name
  })
}

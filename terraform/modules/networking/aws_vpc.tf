resource "aws_vpc" "this" {
  cidr_block           = var.networking.vpc.cidr_block
  enable_dns_support   = var.networking.vpc.enable_dns_support
  enable_dns_hostnames = var.networking.vpc.enable_dns_hostnames

  tags = merge(var.networking.vpc.tags, {
    Name = var.networking.vpc.name
  })
}

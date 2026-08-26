resource "aws_vpc" "this" {
  cidr_block           = var.networking.vpc.cidr_block
  enable_dns_support   = var.networking.vpc.enable_dns_support
  enable_dns_hostnames = var.networking.vpc.enable_dns_hostnames

  tags = merge({
    ManagedBy   = "Terraform"
    Project     = var.shared_configs.project_name
    Environment = var.shared_configs.environment
    }, var.networking.vpc.tags, {
    Name = "${var.shared_configs.project_name}-vpc"
  })
}

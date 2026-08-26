resource "aws_internet_gateway" "this" {
  count  = var.networking.igw.enabled ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags = merge({
    ManagedBy   = "Terraform"
    Project     = var.shared_configs.project_name
    Environment = var.shared_configs.environment
    }, var.networking.vpc.tags, var.networking.igw.tags, {
    Name = "${var.shared_configs.project_name}-igw"
  })
}

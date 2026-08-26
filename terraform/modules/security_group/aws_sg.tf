resource "aws_security_group" "this" {
  for_each = var.security_groups.groups

  vpc_id      = var.security_groups.vpc_id
  name        = "${var.shared_configs.project_name}-${coalesce(each.value.name, each.key)}-sg"
  description = each.value.description

  tags = merge({
    ManagedBy   = "Terraform"
    Project     = var.shared_configs.project_name
    Environment = var.shared_configs.environment
    }, var.security_groups.tags, each.value.tags, {
    Name = "${var.shared_configs.project_name}-${coalesce(each.value.name, each.key)}-sg"
  })
}

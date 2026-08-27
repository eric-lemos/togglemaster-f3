# Resolves vpc_name by AWS tag Name, keeping this module independent of other modules.
data "aws_vpc" "by_name" {
  count = var.security_groups.vpc_id == null ? 1 : 0

  filter {
    name   = "tag:Name"
    values = [var.security_groups.vpc_name]
  }
}

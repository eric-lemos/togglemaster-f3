# Resolves vpc_name, subnet_names and security_group_names by AWS tag Name, keeping this module independent of other modules.
data "aws_vpc" "by_name" {
  count = var.elasticache.subnet_group.vpc_name != null ? 1 : 0

  filter {
    name   = "tag:Name"
    values = [var.elasticache.subnet_group.vpc_name]
  }
}

data "aws_subnet" "by_name" {
  for_each = toset(var.elasticache.subnet_group.subnet_names)

  vpc_id = try(data.aws_vpc.by_name[0].id, var.elasticache.subnet_group.vpc_id)

  filter {
    name   = "tag:Name"
    values = [each.value]
  }
}

data "aws_security_group" "by_name" {
  for_each = toset(flatten([for k, c in var.elasticache.clusters : c.security_group_names]))

  name   = each.value
  vpc_id = try(data.aws_vpc.by_name[0].id, var.elasticache.subnet_group.vpc_id)
}

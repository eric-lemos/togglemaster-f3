# Uses an existing IAM role when explicit ARNs are not provided.
data "aws_iam_role" "default" {
  count = var.eks.iam.cluster_role_arn == null || var.eks.iam.node_role_arn == null ? 1 : 0
  name  = var.eks.iam.role_name
}

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name
}

# Resolves vpc_name, *_subnet_names and security_group_names by AWS tag Name, keeping this module independent of other modules.
data "aws_vpc" "by_name" {
  count = var.eks.cluster.vpc_name != null ? 1 : 0

  filter {
    name   = "tag:Name"
    values = [var.eks.cluster.vpc_name]
  }
}

data "aws_subnet" "by_name" {
  for_each = toset(concat(
    var.eks.cluster.public_subnet_names,
    var.eks.cluster.private_subnet_names,
    flatten([for k, ng in var.eks.node_groups : ng.subnet_names])
  ))

  vpc_id = try(data.aws_vpc.by_name[0].id, var.eks.cluster.vpc_id)

  filter {
    name   = "tag:Name"
    values = [each.value]
  }
}

data "aws_security_group" "by_name" {
  for_each = toset(concat(
    var.eks.cluster.security_group_names,
    flatten([for k, ng in var.eks.node_groups : ng.security_group_names])
  ))

  name   = each.value
  vpc_id = try(data.aws_vpc.by_name[0].id, var.eks.cluster.vpc_id)
}


resource "aws_eks_cluster" "this" {
  name     = var.eks.cluster.name
  role_arn = var.eks.iam.cluster_role_arn != null ? var.eks.iam.cluster_role_arn : data.aws_iam_role.default[0].arn
  version  = var.eks.cluster.kubernetes_version

  access_config {
    authentication_mode                         = var.eks.cluster.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.eks.cluster.bootstrap_cluster_creator_admin_permissions
  }

  vpc_config {
    subnet_ids = concat(
      var.eks.cluster.public_subnet_ids,
      var.eks.cluster.private_subnet_ids,
      [for n in concat(var.eks.cluster.public_subnet_names, var.eks.cluster.private_subnet_names) : data.aws_subnet.by_name[n].id]
    )
    security_group_ids = concat(
      var.eks.cluster.security_group_ids,
      [for n in var.eks.cluster.security_group_names : data.aws_security_group.by_name[n].id]
    )
    endpoint_public_access  = var.eks.cluster.endpoint_public_access
    endpoint_private_access = var.eks.cluster.endpoint_private_access
  }

  tags = merge(var.eks.cluster.tags, {
    Name = var.eks.cluster.name
  })
}

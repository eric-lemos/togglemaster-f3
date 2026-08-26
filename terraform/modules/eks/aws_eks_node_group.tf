resource "aws_eks_node_group" "this" {
  for_each = var.eks.node_groups

  cluster_name = aws_eks_cluster.this.name

  node_group_name = coalesce(each.value.name, each.key)
  node_role_arn   = var.eks.iam.node_role_arn != null ? var.eks.iam.node_role_arn : data.aws_iam_role.default[0].arn
  subnet_ids      = coalesce(each.value.subnet_ids, var.eks.cluster.private_subnet_ids)

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  ami_type       = each.value.ami_type
  instance_types = each.value.instance_types
  disk_size      = each.value.disk_size

  tags = merge(each.value.tags, {
    ManagedBy   = "Terraform"
    Project     = var.shared_configs.project_name
    Environment = var.shared_configs.environment
    Name        = coalesce(each.value.name, each.key)
  })

  depends_on = [aws_eks_cluster.this]
}

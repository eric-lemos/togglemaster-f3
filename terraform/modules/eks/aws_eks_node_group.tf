resource "aws_eks_node_group" "this" {
  for_each = var.eks.node_groups

  cluster_name = aws_eks_cluster.this.name

  node_group_name = coalesce(each.value.name, each.key)
  node_role_arn   = var.eks.iam.node_role_arn != null ? var.eks.iam.node_role_arn : data.aws_iam_role.default[0].arn

  subnet_ids = length(each.value.subnet_ids) + length(each.value.subnet_names) > 0 ? concat(
    each.value.subnet_ids,
    [for n in each.value.subnet_names : data.aws_subnet.by_name[n].id]
    ) : concat(
    var.eks.cluster.private_subnet_ids,
    [for n in var.eks.cluster.private_subnet_names : data.aws_subnet.by_name[n].id]
  )

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  ami_type       = each.value.ami_type
  instance_types = each.value.instance_types
  # disk_size can't be set alongside a launch_template block.
  disk_size = contains(keys(aws_launch_template.this), each.key) ? null : each.value.disk_size

  dynamic "launch_template" {
    for_each = contains(keys(aws_launch_template.this), each.key) ? [aws_launch_template.this[each.key]] : []
    content {
      id      = launch_template.value.id
      version = launch_template.value.latest_version
    }
  }

  tags = merge(each.value.tags, {
    Name = coalesce(each.value.name, each.key)
  })

  depends_on = [aws_eks_cluster.this]
}

# Only created for node groups that declare a custom security group; otherwise nodes inherit the cluster security group.
resource "aws_launch_template" "this" {
  for_each = {
    for k, ng in var.eks.node_groups : k => ng
    if length(ng.security_group_ids) + length(ng.security_group_names) > 0
  }

  name_prefix = "${coalesce(each.value.name, each.key)}-"

  # EKS stops auto-attaching the cluster security group to nodes once a launch template defines security_groups,
  # so the cluster SG must be added explicitly to keep node<->control-plane communication working.
  network_interfaces {
    security_groups = concat(
      [aws_eks_cluster.this.vpc_config[0].cluster_security_group_id],
      each.value.security_group_ids,
      [for n in each.value.security_group_names : data.aws_security_group.by_name[n].id]
    )
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(each.value.tags, {
      Name = coalesce(each.value.name, each.key)
    })
  }
}

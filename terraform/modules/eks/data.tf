# Uses an existing IAM role when explicit ARNs are not provided.
data "aws_iam_role" "default" {
  count = var.eks.iam.cluster_role_arn == null || var.eks.iam.node_role_arn == null ? 1 : 0
  name  = var.eks.iam.role_name
}

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name
}

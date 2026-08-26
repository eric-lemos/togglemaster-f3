output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_arn" {
  value = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_ca" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_auth_token" {
  value = data.aws_eks_cluster_auth.this.token
}

output "cluster_security_group_id" {
  value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "node_group_names" {
  value = { for k, ng in aws_eks_node_group.this : k => ng.node_group_name }
}

output "node_group_arns" {
  value = { for k, ng in aws_eks_node_group.this : k => ng.arn }
}

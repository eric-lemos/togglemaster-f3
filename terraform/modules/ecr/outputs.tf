output "repository_names" {
  value = { for k, repository in aws_ecr_repository.this : k => repository.name }
}

output "repository_urls" {
  value = { for k, repository in aws_ecr_repository.this : k => repository.repository_url }
}

output "repository_arns" {
  value = { for k, repository in aws_ecr_repository.this : k => repository.arn }
}

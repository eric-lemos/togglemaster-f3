output "security_group_ids" {
  value = { for k, sg in aws_security_group.this : k => sg.id }
}

output "security_group_arns" {
  value = { for k, sg in aws_security_group.this : k => sg.arn }
}

output "security_group_names" {
  value = { for k, sg in aws_security_group.this : k => sg.name }
}

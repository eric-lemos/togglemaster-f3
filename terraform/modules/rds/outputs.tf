output "db_subnet_group_name" {
  value = aws_db_subnet_group.this.name
}

output "instance_endpoints" {
  value = { for k, i in aws_db_instance.this : k => i.address }
}

output "instance_identifiers" {
  value = { for k, i in aws_db_instance.this : k => i.identifier }
}

output "instance_arns" {
  value = { for k, i in aws_db_instance.this : k => i.arn }
}

output "db_names" {
  value = { for k, i in aws_db_instance.this : k => i.db_name }
}

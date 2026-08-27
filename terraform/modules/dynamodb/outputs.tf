output "table_names" {
  value = { for k, table in aws_dynamodb_table.this : k => table.name }
}

output "table_arns" {
  value = { for k, table in aws_dynamodb_table.this : k => table.arn }
}

output "table_ids" {
  value = { for k, table in aws_dynamodb_table.this : k => table.id }
}

resource "aws_dynamodb_table" "this" {
  for_each = var.dynamodb.tables

  name         = coalesce(each.value.name, each.key)
  billing_mode = each.value.billing_mode
  hash_key     = each.value.hash_key

  attribute {
    name = each.value.hash_key
    type = each.value.hash_key_type
  }

  point_in_time_recovery {
    enabled = each.value.point_in_time_recovery_enabled
  }

  server_side_encryption {
    enabled = each.value.server_side_encryption_enabled
  }

  tags = merge(var.dynamodb.tags, each.value.tags, {
    Name = coalesce(each.value.name, each.key)
  })
}

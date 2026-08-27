variable "dynamodb" {
  description = "DynamoDB configuration."

  type = object({
    tables = map(object({
      name                           = optional(string)
      hash_key                       = string
      hash_key_type                  = optional(string, "S")
      billing_mode                   = optional(string, "PAY_PER_REQUEST")
      point_in_time_recovery_enabled = optional(bool, true)
      server_side_encryption_enabled = optional(bool, true)
      tags                           = optional(map(string), {})
    }))
    tags = optional(map(string), {})
  })

  validation {
    condition     = alltrue([for k, table in var.dynamodb.tables : contains(["PAY_PER_REQUEST", "PROVISIONED"], table.billing_mode)])
    error_message = "dynamodb.tables.*.billing_mode must be PAY_PER_REQUEST or PROVISIONED."
  }

  validation {
    condition     = alltrue([for k, table in var.dynamodb.tables : contains(["S", "N", "B"], table.hash_key_type)])
    error_message = "dynamodb.tables.*.hash_key_type must be S, N or B."
  }
}

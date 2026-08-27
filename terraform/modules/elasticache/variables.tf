variable "elasticache" {
  description = "ElastiCache configuration (subnet group and cache clusters). Subnet ids and security group ids can be referenced by id or by Name tag."

  type = object({
    subnet_group = optional(object({
      name         = optional(string)
      vpc_id       = optional(string)
      vpc_name     = optional(string) # resolved to id via data source, by VPC Name tag; scopes subnet_names/security_group_names lookups
      subnet_ids   = optional(list(string), [])
      subnet_names = optional(list(string), []) # resolved to ids via data source, by subnet Name tag
    }), {})

    # Map key = logical cache cluster identifier (e.g. "sessions", "cache")
    clusters = map(object({
      name                 = optional(string)
      engine               = optional(string, "redis")
      engine_version       = optional(string, "7.1")
      node_type            = optional(string, "cache.t3.micro")
      num_cache_nodes      = optional(number, 1)
      port                 = optional(number, 6379)
      parameter_group_name = optional(string)
      security_group_ids   = optional(list(string), [])
      security_group_names = optional(list(string), []) # resolved via data source, by SG name
      apply_immediately    = optional(bool, true)
      tags                 = optional(map(string), {})
    }))

    tags = optional(map(string), {})
  })

  validation {
    condition     = length(var.elasticache.subnet_group.subnet_ids) + length(var.elasticache.subnet_group.subnet_names) > 0
    error_message = "elasticache.subnet_group must provide at least one subnet via subnet_ids or subnet_names."
  }
}

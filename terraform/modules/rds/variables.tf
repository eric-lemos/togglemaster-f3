# password is wrapped with sensitive() at usage site (aws_db_instance.tf) instead of marking the whole variable.
variable "rds" {
  description = "RDS configuration (subnet group and DB instances). Subnet ids and security group ids are wired from other modules' outputs."

  type = object({
    subnet_group = optional(object({
      name         = optional(string)
      vpc_id       = optional(string)
      vpc_name     = optional(string) # resolved to id via data source, by VPC Name tag; scopes subnet_names/security_group_names lookups
      subnet_ids   = optional(list(string), [])
      subnet_names = optional(list(string), []) # resolved to ids via data source, by subnet Name tag
    }), {})

    # Map key = logical DB instance identifier (e.g. "flags", "targeting")
    instances = map(object({
      engine                       = optional(string, "postgres")
      engine_version               = optional(string, "16.4")
      instance_class               = optional(string, "db.t3.micro")
      allocated_storage            = optional(number, 20)
      storage_encrypted            = optional(bool, true)
      db_name                      = string
      username                     = string
      password                     = string
      security_group_ids           = optional(list(string), [])
      security_group_names         = optional(list(string), [])
      publicly_accessible          = optional(bool, false)
      skip_final_snapshot          = optional(bool, true)
      multi_az                     = optional(bool, false)
      backup_retention_period      = optional(number, 7)
      monitoring_interval          = optional(number, 0)   # 0 disables Enhanced Monitoring (avoids extra cost)
      performance_insights_enabled = optional(bool, false) # disabled by default (avoids extra cost)
      tags                         = optional(map(string), {})
    }))

    tags = optional(map(string), {})
  })

  validation {
    condition     = length(var.rds.subnet_group.subnet_ids) + length(var.rds.subnet_group.subnet_names) > 0
    error_message = "rds.subnet_group must provide at least one subnet via subnet_ids or subnet_names."
  }
}

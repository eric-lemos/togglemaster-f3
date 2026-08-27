variable "security_groups" {
  description = "Security groups configuration (group definitions and ingress/egress rules)."

  type = object({
    vpc_id   = optional(string)
    vpc_name = optional(string) # resolved to id via data source, by VPC Name tag
    tags     = optional(map(string), {})

    # Map key = logical security group identifier (e.g. "alb", "api", "db")
    groups = map(object({
      name        = optional(string)
      description = optional(string, "Managed by Terraform")
      tags        = optional(map(string), {})

      ingress = optional(list(object({
        description               = optional(string)
        from_port                 = number
        to_port                   = number
        protocol                  = string
        cidr_ipv4                 = optional(string)
        cidr_ipv6                 = optional(string)
        prefix_list_id            = optional(string)
        source_security_group_id  = optional(string)
        source_security_group_key = optional(string)
        self                      = optional(bool, false)
      })), [])

      egress = optional(list(object({
        description               = optional(string)
        from_port                 = number
        to_port                   = number
        protocol                  = string
        cidr_ipv4                 = optional(string)
        cidr_ipv6                 = optional(string)
        prefix_list_id            = optional(string)
        source_security_group_id  = optional(string)
        source_security_group_key = optional(string)
        self                      = optional(bool, false)
        })), [
        {
          description = "Allow all egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_ipv4   = "0.0.0.0/0"
      }])
    }))
  })

  validation {
    condition = alltrue(flatten([
      for sg_key, sg in var.security_groups.groups : [
        for r in sg.ingress :
        length(compact([
          try(r.cidr_ipv4, null),
          try(r.cidr_ipv6, null),
          try(r.prefix_list_id, null),
          try(r.source_security_group_id, null),
          try(r.source_security_group_key, null),
          try(r.self, false) ? "self" : null
        ])) == 1
      ]
    ]))
    error_message = "Each ingress rule must define exactly one source: cidr_ipv4, cidr_ipv6, prefix_list_id, source_security_group_id, source_security_group_key or self=true."
  }

  validation {
    condition = alltrue(flatten([
      for sg_key, sg in var.security_groups.groups : [
        for r in sg.egress :
        length(compact([
          try(r.cidr_ipv4, null),
          try(r.cidr_ipv6, null),
          try(r.prefix_list_id, null),
          try(r.source_security_group_id, null),
          try(r.source_security_group_key, null),
          try(r.self, false) ? "self" : null
        ])) == 1
      ]
    ]))
    error_message = "Each egress rule must define exactly one destination: cidr_ipv4, cidr_ipv6, prefix_list_id, source_security_group_id, source_security_group_key or self=true."
  }

  validation {
    condition = alltrue(flatten([
      for sg_key, sg in var.security_groups.groups : [
        for r in sg.ingress :
        try(r.source_security_group_key, null) == null || contains(keys(var.security_groups.groups), r.source_security_group_key)
      ]
    ]))
    error_message = "ingress.source_security_group_key must reference an existing key in security_groups.groups."
  }

  validation {
    condition = alltrue(flatten([
      for sg_key, sg in var.security_groups.groups : [
        for r in sg.egress :
        try(r.source_security_group_key, null) == null || contains(keys(var.security_groups.groups), r.source_security_group_key)
      ]
    ]))
    error_message = "egress.source_security_group_key must reference an existing key in security_groups.groups."
  }

  validation {
    condition     = var.security_groups.vpc_id != null || var.security_groups.vpc_name != null
    error_message = "security_groups must provide either vpc_id or vpc_name."
  }
}

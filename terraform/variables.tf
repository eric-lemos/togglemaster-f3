variable "shared_configs" {
  description = "Shared configuration used across modules (region, project name, etc)."

  type = object({
    aws_region   = optional(string)
    project_name = optional(string)
  })

  default = {}
}

variable "networking" {
  description = "Complete networking configuration, passed through to the networking module."

  type = object({
    vpc = object({
      name                 = string
      cidr_block           = string
      enable_dns_support   = optional(bool, true)
      enable_dns_hostnames = optional(bool, true)
      tags                 = optional(map(string), {})
    })

    igw = optional(object({
      enabled = optional(bool, true)
      name    = optional(string, "igw")
      tags    = optional(map(string), {})
    }), {})

    subnet = map(object({
      cidr_block              = string
      availability_zone       = optional(string)
      type                    = string
      map_public_ip_on_launch = optional(bool)
      tags                    = optional(map(string), {})
    }))

    natgw = optional(map(object({
      subnet_key = string
      tags       = optional(map(string), {})
      eip_tags   = optional(map(string), {})
    })), {})

    rtb = map(object({
      subnet_keys = list(string)
      routes = optional(list(object({
        cidr_block      = string
        gateway_key     = optional(string)
        nat_gateway_key = optional(string)
      })), [])
      tags = optional(map(string), {})
    }))
  })
}

variable "shared_configs" {
  description = "Global shared configuration used to standardize resource naming and tagging."

  type = object({
    aws_region   = string
    project_name = string
    environment  = string
  })
}

variable "networking" {
  description = "Complete networking resources configuration (VPC, IGW, subnets, NAT gateways and route tables)."

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

    # Map key = logical subnet identifier (e.g. "public-a", "private-b")
    subnet = map(object({
      cidr_block              = string
      availability_zone       = optional(string)
      type                    = string # "public" or "private"
      map_public_ip_on_launch = optional(bool)
      tags                    = optional(map(string), {})
    }))

    # Map key = logical NAT gateway identifier
    natgw = optional(map(object({
      subnet_key = string # existing key in subnet (must be public)
      tags       = optional(map(string), {})
      eip_tags   = optional(map(string), {})
    })), {})

    # Map key = logical route table identifier
    rtb = map(object({
      subnet_keys = list(string) # existing keys in subnet associated with this route table
      routes = optional(list(object({
        cidr_block      = string
        gateway_key     = optional(string) # "igw" to route through the Internet Gateway
        nat_gateway_key = optional(string) # existing key in natgw
      })), [])
      tags = optional(map(string), {})
    }))
  })

  validation {
    condition     = alltrue([for k, s in var.networking.subnet : contains(["public", "private"], s.type)])
    error_message = "networking.subnet.*.type must be \"public\" or \"private\"."
  }

  validation {
    condition     = alltrue([for k, n in var.networking.natgw : contains(keys(var.networking.subnet), n.subnet_key)])
    error_message = "networking.natgw.*.subnet_key must reference an existing key in networking.subnet."
  }

  validation {
    condition = alltrue([
      for k, rt in var.networking.rtb :
      alltrue([for sk in rt.subnet_keys : contains(keys(var.networking.subnet), sk)])
    ])
    error_message = "networking.rtb.*.subnet_keys must reference existing keys in networking.subnet."
  }

  validation {
    condition = alltrue([
      for k, rt in var.networking.rtb :
      alltrue([
        for r in rt.routes :
        r.nat_gateway_key == null || contains(keys(var.networking.natgw), r.nat_gateway_key)
      ])
    ])
    error_message = "networking.rtb.*.routes.*.nat_gateway_key must reference an existing key in networking.natgw."
  }

  validation {
    condition = var.networking.igw.enabled || alltrue([
      for k, rt in var.networking.rtb :
      alltrue([for r in rt.routes : r.gateway_key != "igw"])
    ])
    error_message = "networking.rtb.*.routes.*.gateway_key cannot be \"igw\" when networking.igw.enabled is false."
  }
}

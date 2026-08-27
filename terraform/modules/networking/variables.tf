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
      enabled = optional(bool, false)
      name    = optional(string, "igw")
      tags    = optional(map(string), {})
    }), {})

    # Map key = logical subnet identifier (e.g. "public-a", "private-b")
    subnet = map(object({
      name                    = optional(string) # defaults to the map key when not set
      cidr_block              = string
      availability_zone       = optional(string)
      type                    = string # "public" or "private"
      map_public_ip_on_launch = optional(bool)
      tags                    = optional(map(string), {})
    }))

    # Map key = logical NAT gateway identifier
    natgw = optional(map(object({
      name        = optional(string) # defaults to the map key when not set
      subnet_name = string           # existing subnet name (or key, when name is unset) in subnet
      tags        = optional(map(string), {})
      eip_tags    = optional(map(string), {})
    })), {})

    # Map key = logical route table identifier
    rtb = map(object({
      name         = optional(string) # defaults to the map key when not set
      subnet_names = list(string)     # existing subnet names (or keys) associated with this route table
      routes = optional(list(object({
        cidr_block       = string
        gateway_name     = optional(string) # existing Internet Gateway name
        nat_gateway_name = optional(string) # existing NAT gateway name
      })), [])
      tags = optional(map(string), {})
    }))
  })

  validation {
    condition     = alltrue([for k, s in var.networking.subnet : contains(["public", "private"], s.type)])
    error_message = "networking.subnet.*.type must be \"public\" or \"private\"."
  }

  validation {
    condition     = alltrue([for k, n in var.networking.natgw : contains([for sk, s in var.networking.subnet : coalesce(s.name, sk)], n.subnet_name)])
    error_message = "networking.natgw.*.subnet_name must reference an existing subnet name (or key) in networking.subnet."
  }

  validation {
    condition = alltrue([
      for k, rt in var.networking.rtb :
      alltrue([for sn in rt.subnet_names : contains([for sk, s in var.networking.subnet : coalesce(s.name, sk)], sn)])
    ])
    error_message = "networking.rtb.*.subnet_names must reference existing subnet names (or keys) in networking.subnet."
  }

  validation {
    condition = alltrue([
      for k, rt in var.networking.rtb :
      alltrue([
        for r in rt.routes :
        r.nat_gateway_name == null || contains([for nk, n in var.networking.natgw : coalesce(n.name, nk)], r.nat_gateway_name)
      ])
    ])
    error_message = "networking.rtb.*.routes.*.nat_gateway_name must reference an existing NAT gateway name (or key) in networking.natgw."
  }

  validation {
    condition = var.networking.igw.enabled || alltrue([
      for k, rt in var.networking.rtb :
      alltrue([for r in rt.routes : r.gateway_name != var.networking.igw.name])
    ])
    error_message = "networking.rtb.*.routes.*.gateway_name cannot reference the Internet Gateway when networking.igw.enabled is false."
  }
}

variable "shared_configs" {
  description = "Shared configuration used across modules (region, project name, etc)."

  type = object({
    aws_region   = string
    project_name = string
    environment  = string
  })
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

variable "eks" {
  description = "EKS configuration passed through to the EKS module. Networking subnets are wired from module outputs."

  type = object({
    cluster = object({
      name                                        = string
      kubernetes_version                          = optional(string, "1.33")
      public_subnet_ids                           = optional(list(string), [])
      private_subnet_ids                          = optional(list(string), [])
      security_group_ids                          = optional(list(string), [])
      endpoint_public_access                      = optional(bool, true)
      endpoint_private_access                     = optional(bool, true)
      authentication_mode                         = optional(string, "API_AND_CONFIG_MAP")
      bootstrap_cluster_creator_admin_permissions = optional(bool, true)
      tags                                        = optional(map(string), {})
    })

    iam = optional(object({
      role_name        = optional(string)
      cluster_role_arn = optional(string)
      node_role_arn    = optional(string)
    }), {})

    node_groups = optional(map(object({
      name           = optional(string)
      subnet_ids     = optional(list(string))
      min_size       = optional(number, 1)
      max_size       = optional(number, 4)
      desired_size   = optional(number, 2)
      ami_type       = optional(string, "AL2023_x86_64_STANDARD")
      instance_types = optional(list(string), ["t3.medium"])
      disk_size      = optional(number, 20)
      tags           = optional(map(string), {})
    })), {})
  })
}

variable "security_groups" {
  description = "Security groups configuration passed through to the security_group module. VPC id is wired from networking outputs."

  type = object({
    tags = optional(map(string), {})

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
        }
      ])
    }))
  })
}

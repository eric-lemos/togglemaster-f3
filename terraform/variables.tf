variable "provider_configs" {
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
      enabled = optional(bool, false)
      name    = optional(string, "igw")
      tags    = optional(map(string), {})
    }), {})

    subnet = map(object({
      name                    = optional(string)
      cidr_block              = string
      availability_zone       = optional(string)
      type                    = string
      map_public_ip_on_launch = optional(bool)
      tags                    = optional(map(string), {})
    }))

    natgw = optional(map(object({
      name        = optional(string)
      subnet_name = string
      tags        = optional(map(string), {})
      eip_tags    = optional(map(string), {})
    })), {})

    rtb = map(object({
      name         = optional(string)
      subnet_names = list(string)
      routes = optional(list(object({
        cidr_block       = string
        gateway_name     = optional(string)
        nat_gateway_name = optional(string)
      })), [])
      tags = optional(map(string), {})
    }))
  })
}

variable "security_groups" {
  description = "Security groups configuration passed through to the security_group module. VPC can be referenced by id or by Name tag."

  type = object({
    vpc_id   = optional(string)
    vpc_name = optional(string)
    tags     = optional(map(string), {})

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

variable "eks" {
  description = "EKS configuration (cluster, IAM role references and managed node groups)."

  type = object({
    cluster = object({
      name                                        = string
      kubernetes_version                          = optional(string, "1.33")
      vpc_id                                      = optional(string)
      vpc_name                                    = optional(string) # resolved to id via data source, by VPC Name tag
      public_subnet_ids                           = optional(list(string), [])
      public_subnet_names                         = optional(list(string), []) # resolved via data source, by subnet Name tag
      private_subnet_ids                          = optional(list(string), [])
      private_subnet_names                        = optional(list(string), []) # resolved via data source, by subnet Name tag
      security_group_ids                          = optional(list(string), [])
      security_group_names                        = optional(list(string), []) # resolved via data source, by SG name
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
      name                 = optional(string)
      subnet_ids           = optional(list(string), [])
      subnet_names         = optional(list(string), []) # resolved via data source, by subnet Name tag
      security_group_ids   = optional(list(string), [])
      security_group_names = optional(list(string), []) # resolved via data source, by SG name; applied to nodes via a launch template
      min_size             = optional(number, 1)
      max_size             = optional(number, 4)
      desired_size         = optional(number, 2)
      ami_type             = optional(string, "AL2023_x86_64_STANDARD")
      instance_types       = optional(list(string), ["t3.medium"])
      disk_size            = optional(number, 20)
      tags                 = optional(map(string), {})
    })), {})
  })
}

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
      identifier                   = optional(string)
      engine                       = optional(string, "postgres")
      engine_version               = optional(string, "16.4")
      instance_class               = optional(string, "db.t3.micro")
      allocated_storage            = optional(number, 20)
      storage_encrypted            = optional(bool, true)
      db_name                      = optional(string, "postgres")
      username                     = string
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
    condition = alltrue([
      for k, i in var.rds.instances :
      can(regex("^[A-Za-z][A-Za-z0-9-]{0,62}$", coalesce(i.identifier, k)))
    ])
    error_message = "rds.instances.*.identifier must start with a letter and contain only letters, numbers or hyphens (up to 63 characters)."
  }

  validation {
    condition = alltrue([
      for k, i in var.rds.instances :
      can(regex("^[A-Za-z][A-Za-z0-9]*$", i.db_name))
    ])
    error_message = "rds.instances.*.db_name must start with a letter and contain only alphanumeric characters."
  }
}

# Never commit real values; supply via a gitignored secrets file (e.g. secrets.auto.tfvars) or TF_VAR_rds_instance_passwords.
variable "rds_instance_passwords" {
  description = "Master user password for each RDS instance key defined in rds.instances."
  type        = map(string)
  sensitive   = true

  validation {
    condition     = alltrue([for k, i in var.rds.instances : contains(keys(var.rds_instance_passwords), k)])
    error_message = "rds_instance_passwords must provide a password for every key defined in rds.instances."
  }

  validation {
    condition = alltrue([
      for k, password in var.rds_instance_passwords :
      length(password) >= 8 &&
      can(regex("^[\\x20-\\x7E]+$", password)) &&
      !can(regex("[/@\" ]", password))
    ])
    error_message = "RDS passwords must contain at least 8 printable ASCII characters and must not contain '/', '@', '\"' or spaces."
  }
}

variable "elasticache" {
  description = "ElastiCache configuration passed through to the elasticache module. VPC and subnets can be referenced by id or by Name tag."

  type = object({
    subnet_group = optional(object({
      name         = optional(string)
      vpc_id       = optional(string)
      vpc_name     = optional(string)
      subnet_ids   = optional(list(string), [])
      subnet_names = optional(list(string), [])
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
      security_group_names = optional(list(string), [])
      apply_immediately    = optional(bool, true)
      tags                 = optional(map(string), {})
    }))

    tags = optional(map(string), {})
  })
}

variable "dynamodb" {
  description = "DynamoDB configuration passed through to the dynamodb module."

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
}

variable "sqs" {
  description = "SQS configuration passed through to the sqs module."

  type = object({
    queues = map(object({
      name                        = optional(string)
      visibility_timeout_seconds  = optional(number, 60)
      message_retention_seconds   = optional(number, 86400)
      receive_wait_time_seconds   = optional(number, 0)
      fifo_queue                  = optional(bool, false)
      content_based_deduplication = optional(bool, false)
      sqs_managed_sse_enabled     = optional(bool, true)
      tags                        = optional(map(string), {})
    }))
    tags = optional(map(string), {})
  })
}

variable "ecr" {
  description = "ECR repository configuration passed through to the ecr module."

  type = object({
    repositories = map(object({
      name                 = optional(string)
      image_tag_mutability = optional(string, "IMMUTABLE")
      scan_on_push         = optional(bool, true)
      tags                 = optional(map(string), {})
    }))
    tags = optional(map(string), {})
  })
}

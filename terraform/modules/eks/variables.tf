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

  validation {
    condition = (
      length(var.eks.cluster.public_subnet_ids) + length(var.eks.cluster.public_subnet_names) +
      length(var.eks.cluster.private_subnet_ids) + length(var.eks.cluster.private_subnet_names)
    ) > 0
    error_message = "eks.cluster must provide at least one subnet via *_subnet_ids or *_subnet_names."
  }

  validation {
    condition     = contains(["API", "API_AND_CONFIG_MAP", "CONFIG_MAP"], var.eks.cluster.authentication_mode)
    error_message = "eks.cluster.authentication_mode must be one of: API, API_AND_CONFIG_MAP or CONFIG_MAP."
  }

  validation {
    condition = alltrue([
      for k, ng in var.eks.node_groups :
      ng.min_size <= ng.desired_size && ng.desired_size <= ng.max_size
    ])
    error_message = "eks.node_groups.* requires min_size <= desired_size <= max_size."
  }

  validation {
    condition = alltrue([
      for k, ng in var.eks.node_groups :
      length(ng.subnet_ids) + length(ng.subnet_names) > 0 ||
      length(var.eks.cluster.private_subnet_ids) + length(var.eks.cluster.private_subnet_names) > 0
    ])
    error_message = "Each node group must have at least one subnet, either via node_group.subnet_ids/subnet_names or eks.cluster.private_subnet_ids/private_subnet_names."
  }
}

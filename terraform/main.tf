module "networking" {
  source         = "./modules/networking"
  shared_configs = var.shared_configs
  networking     = var.networking
}

module "security_group" {
  source         = "./modules/security_group"
  shared_configs = var.shared_configs

  security_groups = merge(var.security_groups, {
    vpc_id = module.networking.vpc_id
  })
}

module "eks" {
  source         = "./modules/eks"
  shared_configs = var.shared_configs

  eks = {
    cluster = merge(var.eks.cluster, {
      public_subnet_ids  = module.networking.public_subnet_ids
      private_subnet_ids = module.networking.private_subnet_ids
      security_group_ids = compact(concat(
        var.eks.cluster.security_group_ids,
        [try(module.security_group.security_group_ids["eks-cluster"], null)]
      ))
    })

    iam = var.eks.iam

    node_groups = {
      for k, ng in var.eks.node_groups : k => merge(ng, {
        subnet_ids = ng.subnet_ids != null ? ng.subnet_ids : module.networking.private_subnet_ids
      })
    }
  }
}

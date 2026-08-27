module "networking" {
  source     = "./modules/networking"
  networking = var.networking
}

module "security_group" {
  source          = "./modules/security_group"
  security_groups = var.security_groups

  depends_on = [module.networking]
}

module "eks" {
  source = "./modules/eks"
  eks    = var.eks

  depends_on = [module.networking, module.security_group]
}

module "rds" {
  source = "./modules/rds"

  rds = merge(var.rds, {
    instances = {
      for k, i in var.rds.instances : k => merge(i, {
        password = var.rds_instance_passwords[k]
      })
    }
  })

  depends_on = [module.networking, module.security_group]
}

module "elasticache" {
  source      = "./modules/elasticache"
  elasticache = var.elasticache

  depends_on = [module.networking, module.security_group]
}

module "dynamodb" {
  source   = "./modules/dynamodb"
  dynamodb = var.dynamodb
}

module "sqs" {
  source = "./modules/sqs"
  sqs    = var.sqs
}

module "ecr" {
  source = "./modules/ecr"
  ecr    = var.ecr
}

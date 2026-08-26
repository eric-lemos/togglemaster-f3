shared_configs = {
  aws_region   = "us-east-1"
  project_name = "togglemaster"
  environment  = "dev"
}

networking = {
  vpc = {
    name       = "togglemaster-vpc"
    cidr_block = "10.0.0.0/21"
  }

  igw = {
    enabled = true
    name    = "togglemaster-igw"
  }

  subnet = {
    public-a = {
      cidr_block              = "10.0.1.0/24"
      availability_zone       = "us-east-1a"
      type                    = "public"
      map_public_ip_on_launch = true
    }

    public-b = {
      cidr_block              = "10.0.2.0/24"
      availability_zone       = "us-east-1b"
      type                    = "public"
      map_public_ip_on_launch = true
    }

    private-eks-a = {
      cidr_block        = "10.0.3.0/24"
      availability_zone = "us-east-1a"
      type              = "private"
    }

    private-eks-b = {
      cidr_block        = "10.0.4.0/24"
      availability_zone = "us-east-1b"
      type              = "private"
    }

    private-data-a = {
      cidr_block        = "10.0.5.0/24"
      availability_zone = "us-east-1a"
      type              = "private"
    }

    private-data-b = {
      cidr_block        = "10.0.6.0/24"
      availability_zone = "us-east-1b"
      type              = "private"
    }
  }

  natgw = {
    a = { subnet_key = "public-a" }
    b = { subnet_key = "public-b" }
  }

  rtb = {
    public = {
      subnet_keys = ["public-a", "public-b"]
      routes = [
        {
          cidr_block  = "0.0.0.0/0"
          gateway_key = "igw"
        }
      ]
    }

    private-a = {
      subnet_keys = ["private-eks-a", "private-data-a"]
      routes = [
        {
          cidr_block      = "0.0.0.0/0"
          nat_gateway_key = "a"
        }
      ]
    }

    private-b = {
      subnet_keys = ["private-eks-b", "private-data-b"]
      routes = [
        {
          cidr_block      = "0.0.0.0/0"
          nat_gateway_key = "b"
        }
      ]
    }
  }
}

security_groups = {
  groups = {
    eks-cluster = {
      description = "Security group for EKS cluster"

      ingress = [
        {
          description               = "Allow all traffic from itself"
          from_port                 = 0
          to_port                   = 0
          protocol                  = "-1"
          source_security_group_key = "eks-cluster"
        },
        {
          description = "Allow NodePort range from internet"
          from_port   = 30000
          to_port     = 32767
          protocol    = "tcp"
          cidr_ipv4   = "0.0.0.0/0"
        }
      ]

      egress = [
        {
          description = "Allow all outbound"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_ipv4   = "0.0.0.0/0"
        }
      ]
    }

    rds = {
      description = "Security group for RDS"

      ingress = [
        {
          description               = "Allow PostgreSQL from EKS cluster SG"
          from_port                 = 5432
          to_port                   = 5432
          protocol                  = "tcp"
          source_security_group_key = "eks-cluster"
        }
      ]
    }

    redis = {
      description = "Security group for Redis"

      ingress = [
        {
          description               = "Allow Redis from EKS cluster SG"
          from_port                 = 6379
          to_port                   = 6379
          protocol                  = "tcp"
          source_security_group_key = "eks-cluster"
        }
      ]
    }
  }
}

eks = {
  cluster = {
    name                                        = "togglemaster-eks-cluster"
    kubernetes_version                          = "1.35"
    endpoint_public_access                      = true
    endpoint_private_access                     = false
    bootstrap_cluster_creator_admin_permissions = true
  }

  iam = {
    role_name = "LabRole"
  }

  node_groups = {
    ng1 = {
      name           = "togglemaster-eks-ng1"
      min_size       = 1
      max_size       = 4
      desired_size   = 2
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]
      disk_size      = 20
    }
  }
}

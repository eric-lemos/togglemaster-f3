shared_configs = {
  aws_region = "us-east-1"
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

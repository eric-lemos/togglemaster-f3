terraform {
  required_version = ">= 1.11"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.provider_configs.aws_region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = var.provider_configs.project_name
      Environment = var.provider_configs.environment
    }
  }
}

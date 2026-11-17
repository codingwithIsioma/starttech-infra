# ============================================================
# SECTION: PROVIDERS
# ============================================================
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# ============================================================
# SECTION: MODULES
# ============================================================
# 1. Networking Module
module "networking" {
  source = "./modules/networking"

  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name_prefix
}

# 2. EKS Module
module "eks" {
  source = "./modules/eks"

  project_name       = var.project_name_prefix
  private_subnet_ids = module.networking.private_subnet_ids
}

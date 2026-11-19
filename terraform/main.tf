# ============================================================
# SECTION: PROVIDERS
# ============================================================
terraform {
  backend "s3" {
    key          = "starttech/terraform.tfstate"
    use_lockfile = true
  }
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

  project_name = var.project_name_prefix
  vpc_cidr     = var.vpc_cidr
}

# 2. EKS Module
module "eks" {
  source = "./modules/eks"

  project_name       = var.project_name_prefix
  private_subnet_ids = module.networking.private_subnet_ids
}

# 3. Storage Module
module "storage" {
  source = "./modules/storage"

  project_name                = var.project_name_prefix
  cloudfront_distribution_arn = module.cdn.cloudfront-distribution-arn
}

# 4. CDN Module
module "cdn" {
  source = "./modules/cdn"

  project_name                   = var.project_name_prefix
  s3-bucket-regional-domain-name = module.storage.bucket-regional-domain-name
}

# 5. Database Module
module "database" {
  source = "./modules/database"

  project_name       = var.project_name_prefix
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  worker_node_sg_id  = module.eks.worker_node_sg_id
}

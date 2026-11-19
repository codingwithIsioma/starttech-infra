#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
STATE_BUCKET="starttech-tfstate-${ACCOUNT_ID}"

# 1. Bootstrap the state bucket (only creates it the first time)
if ! aws s3api head-bucket --bucket "$STATE_BUCKET" 2>/dev/null; then
  echo "Creating state bucket $STATE_BUCKET"
  aws s3api create-bucket --bucket "$STATE_BUCKET" --region "$REGION"
  aws s3api put-bucket-versioning --bucket "$STATE_BUCKET" \
    --versioning-configuration Status=Enabled
  aws s3api put-public-access-block --bucket "$STATE_BUCKET" \
    --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
fi

# 2. Run Terraform against it
cd "$(dirname "$0")/../terraform"
terraform init -backend-config="bucket=${STATE_BUCKET}" -backend-config="region=${REGION}"
terraform fmt -check -recursive
terraform validate
terraform apply -auto-approve

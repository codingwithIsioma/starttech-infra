# ============================================================
# SECTION: S3 BUCKET - FRONTEND
# ============================================================

data "aws_caller_identity" "current" {}

# Private S3 bucket holding the React frontend build
resource "aws_s3_bucket" "frontend-bucket" {
  bucket        = "starttech-frontend-bucket-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-frontend-bucket"
  }
}

# Block all public access - the bucket is only read through CloudFront
resource "aws_s3_bucket_public_access_block" "block-frontend-bucket" {
  bucket = aws_s3_bucket.frontend-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CLOUDFRONT DISTRIBUTION ACCESS AND POLICY CONFIGURATION
data "aws_iam_policy_document" "origin_bucket_policy" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.frontend-bucket.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [var.cloudfront_distribution_arn]
    }
  }
}

# Attach the policy above so only our CloudFront distribution can read objects
resource "aws_s3_bucket_policy" "frontend-bucket-policy" {
  bucket = aws_s3_bucket.frontend-bucket.bucket
  policy = data.aws_iam_policy_document.origin_bucket_policy.json

}

# ============================================================
# SECTION: ECR REPOSITORY - BACKEND
# ============================================================
# Container registry for the backend API image
resource "aws_ecr_repository" "backend-repository" {
  name = "starttech-backend-api"

  tags = {
    Name = "${var.project_name}-backend-repository"
  }
}
# ============================================================
# SECTION: S3 BUCKET - FRONTEND
# ============================================================

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "frontend-bucket" {
  bucket = "starttech-frontend-bucket-${data.aws_caller_identity.current.account_id}"
}

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

resource "aws_s3_bucket_policy" "frontend-bucket-policy" {
  bucket = aws_s3_bucket.frontend-bucket.bucket
  policy = data.aws_iam_policy_document.origin_bucket_policy.json

}

# ============================================================
# SECTION: ECR REPOSITORY - BACKEND
# ============================================================
resource "aws_ecr_repository" "backend-repository" {
  name = "starttech-backend-api"
}
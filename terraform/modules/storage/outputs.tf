output "bucket-name" {
  description = "The S3 bucket name"
  value       = aws_s3_bucket.frontend-bucket.bucket
}

output "bucket-regional-domain-name" {
  description = "The S3 bucket's regional domain name"
  value       = aws_s3_bucket.frontend-bucket.bucket_regional_domain_name
}

output "ecr-repository-url" {
  description = "The URL for the ECR repository"
  value       = aws_ecr_repository.backend-repository.repository_url
}
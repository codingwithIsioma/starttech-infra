output "cloudfront-distribution-arn" {
  description = "The CloudFront Distribution ARN"
  value       = aws_cloudfront_distribution.s3-distribution.arn
}

output "cloudfront-distribution-id" {
  description = "The CloudFront Distribution ID"
  value       = aws_cloudfront_distribution.s3-distribution.id
}

output "cloudfront-distribution-domain-name" {
  description = "The CloudFront Distribution domain name"
  value       = aws_cloudfront_distribution.s3-distribution.domain_name
}
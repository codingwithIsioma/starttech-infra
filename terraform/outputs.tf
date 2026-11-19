output "vpc_id" {
  description = "The VPC id"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "The id's of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "The id's of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "cluster_name" {
  description = "The Cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for the kubernetes cluster"
  value       = module.eks.cluster_endpoint
}

output "cloudfront_distribution_id" {
  description = "The CloudFront Distribution ID"
  value       = module.cdn.cloudfront-distribution-id
}

output "cloudfront_domain_name" {
  description = "The CloudFront Distribution domain name"
  value       = module.cdn.cloudfront-distribution-domain-name
}

output "frontend_bucket_name" {
  description = "The S3 bucket name"
  value       = module.storage.bucket-name
}

output "ecr_repository_url" {
  description = "The URL for the ECR repository"
  value       = module.storage.ecr-repository-url
}

output "redis_host" {
  description = "The Redis endpoint"
  value       = module.database.redis_host
}


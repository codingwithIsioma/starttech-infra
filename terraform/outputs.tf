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

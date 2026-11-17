output "cluster_name" {
  description = "The Cluster name"
  value       = aws_eks_cluster.control_plane.name
}

output "cluster_endpoint" {
  description = "Endpoint for the kubernetes cluster"
  value       = aws_eks_cluster.control_plane.endpoint
}
output "cluster_name" {
  description = "The Cluster name"
  value       = aws_eks_cluster.control_plane.name
}

output "cluster_endpoint" {
  description = "Endpoint for the kubernetes cluster"
  value       = aws_eks_cluster.control_plane.endpoint
}

output "worker_node_sg_id" {
  description = "The Worker nodes security group ID"
  value       = aws_eks_cluster.control_plane.vpc_config[0].cluster_security_group_id
}

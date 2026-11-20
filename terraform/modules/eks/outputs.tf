output "cluster_name" {
  description = "The Cluster name"
  value       = aws_eks_cluster.control_plane.name
}

output "cluster_endpoint" {
  description = "Endpoint for the kubernetes cluster"
  value       = aws_eks_cluster.control_plane.endpoint
}

output "cluster_ca_certificate" {
  description = "Cluser certification for authentication"
  value       = aws_eks_cluster.control_plane.certificate_authority[0].data
}

output "worker_node_sg_id" {
  description = "The Worker nodes security group ID"
  value       = aws_eks_cluster.control_plane.vpc_config[0].cluster_security_group_id
}

output "lb_controller_role_arn" {
  value = aws_iam_role.lb_controller.arn
}

output "alb_dns_name" {
  value = kubernetes_ingress_v1.alb_base.status[0].load_balancer[0].ingress[0].hostname
}
variable "project_name" {
  description = "The name of the project. Used to prefix and tag resources."
  type        = string
}

variable "private_subnet_ids" {
  description = "The private subnets the ElastiCache Redis node will live in"
  type        = list(string)
}

variable "worker_node_sg_id" {
  description = "The Worker nodes security group ID"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

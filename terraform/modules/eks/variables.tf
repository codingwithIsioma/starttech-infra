variable "private_subnet_ids" {
  description = "The private subnets the EKS Worker Nodes will live in"
  type        = list(string)
}

variable "project_name" {
  description = "The name of the project. Used to prefix and tag resources."
  type        = string
}

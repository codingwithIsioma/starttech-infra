variable "aws_region" {
  description = "AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The IP range (CIDR block) for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name_prefix" {
  description = "The name of the project. Used to prefix and tag resources."
  type        = string
  default     = "starttech"
}

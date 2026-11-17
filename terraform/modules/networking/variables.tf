variable "vpc_cidr" {
  description = "The IP range (CIDR block) for the VPC."
  type        = string
}

variable "public_subnet_cidr_block" {
  description = "The CIDR block the public subnet's resources can reside in the VPC."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr_block" {
  description = "The CIDR block the private subnet's resources can reside in the VPC."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "project_name" {
  description = "The name of the project. Used to prefix and tag resources."
  type        = string
}

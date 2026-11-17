output "vpc_id" {
  description = "The VPC id"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "The id's of the public subnets"
  value       = [aws_subnet.public[0].id, aws_subnet.public[1].id]
}

output "private_subnet_ids" {
  description = "The id's of the private subnets"
  value       = [aws_subnet.private[0].id, aws_subnet.private[1].id]
}
variable "project_name" {
  description = "The name of the project. Used to prefix and tag resources."
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "The CloudFront Distribution ARN"
  type        = string
}

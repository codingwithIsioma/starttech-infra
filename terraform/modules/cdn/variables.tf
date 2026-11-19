variable "project_name" {
  description = "The name of the project. Used to prefix and tag resources."
  type        = string
}

variable "s3-bucket-regional-domain-name" {
  description = "The S3 bucket's regional domain name"
  type        = string
}

# ============================================================
# SECTION: CLOUDFRONT DISTRIBUTION
# ============================================================

locals {
  s3_origin_id  = "S3-Frontend"
  alb_origin_id = "ALB-Backend"
}

# Origin Access Control - lets CloudFront sign its requests to the private S3 bucket
resource "aws_cloudfront_origin_access_control" "main-oac" {
  name                              = "${var.project_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront distribution - serves the frontend from S3 and forwards /api/* to the ALB
resource "aws_cloudfront_distribution" "s3-distribution" {
  enabled             = true
  default_root_object = "index.html"

  # Origin 1: S3 Bucket (React)
  origin {
    domain_name              = var.s3-bucket-regional-domain-name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.main-oac.id
  }

  # Origin 2: ALB (Backend)
  origin {
    domain_name = var.alb_dns_name
    origin_id   = local.alb_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Default Behavior -> Routes to S3
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Ordered Behavior -> Routes /api/* to ALB
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.alb_origin_id

    forwarded_values {
      cookies {
        forward = "all"
      }
      headers      = ["*"]
      query_string = true
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  # Custom Error Responses
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "${var.project_name}-cloudfront"
  }
}

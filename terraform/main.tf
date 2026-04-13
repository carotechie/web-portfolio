terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ---------------------------------------------------------------
  # STEP 1 — First time (before bootstrap is run)
  # Use local backend. Run: terraform init && terraform apply
  # ---------------------------------------------------------------
  # backend "local" {}

  # ---------------------------------------------------------------
  # STEP 2 — After bootstrap creates tf-state-carotechie bucket
  # Comment out backend "local" above, uncomment this block,
  # then run: terraform init -migrate-state
  # ---------------------------------------------------------------
  backend "s3" {
    bucket  = "tf-state-carotechie"
    key     = "website/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Carolina-Website"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "Carolina Herrera Monteza"
    }
  }
}

# S3 bucket for static website hosting (Free tier eligible)
resource "aws_s3_bucket" "website" {
  bucket = var.domain_name

  tags = {
    Name = "Carolina Website Bucket"
  }
}

# S3 bucket website configuration
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# S3 bucket public access block configuration
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 bucket policy for public read access
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.website]
}

# CloudFront Origin Access Identity (for better security - optional)
resource "aws_cloudfront_origin_access_identity" "website" {
  comment = "OAI for ${var.domain_name}"
}

# CloudFront distribution (Free tier: 1TB data transfer out per month)
resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  aliases             = var.enable_custom_domain ? [var.domain_name] : []

  origin {
    domain_name = aws_s3_bucket_website_configuration.website.website_endpoint
    origin_id   = "S3-${var.domain_name}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.domain_name}"

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
    compress               = true
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = !var.enable_custom_domain
    acm_certificate_arn            = var.enable_custom_domain ? var.acm_certificate_arn : null
    ssl_support_method             = var.enable_custom_domain ? "sni-only" : null
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  tags = {
    Name = "Carolina Website CDN"
  }
}

# Data source for existing Route53 hosted zone (if zone_id provided)
data "aws_route53_zone" "existing" {
  count   = var.enable_custom_domain && var.route53_zone_id != "" ? 1 : 0
  zone_id = var.route53_zone_id
}

# Create new Route53 hosted zone only if zone_id not provided
resource "aws_route53_zone" "main" {
  count = var.enable_custom_domain && var.route53_zone_id == "" ? 1 : 0
  name  = var.domain_name

  tags = {
    Name = "Carolina Website DNS"
  }
}

# Local value to determine which zone to use
locals {
  zone_id = var.enable_custom_domain ? (
    var.route53_zone_id != "" ? data.aws_route53_zone.existing[0].zone_id : aws_route53_zone.main[0].zone_id
  ) : ""
}

# Route53 A record for CloudFront
resource "aws_route53_record" "website" {
  count   = var.enable_custom_domain ? 1 : 0
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

# Route53 AAAA record for CloudFront (IPv6)
resource "aws_route53_record" "website_ipv6" {
  count   = var.enable_custom_domain ? 1 : 0
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.website.id
}

output "s3_bucket_website_endpoint" {
  description = "S3 bucket website endpoint"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.website.arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.website.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.website.domain_name
}

output "cloudfront_url" {
  description = "Full CloudFront URL"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID (existing or newly created)"
  value       = var.enable_custom_domain ? local.zone_id : null
}

output "route53_name_servers" {
  description = "Route53 name servers (only if new zone was created)"
  value       = var.enable_custom_domain && var.route53_zone_id == "" ? aws_route53_zone.main[0].name_servers : null
}

output "using_existing_zone" {
  description = "Whether using an existing Route53 hosted zone"
  value       = var.enable_custom_domain && var.route53_zone_id != ""
}

output "website_url" {
  description = "Website URL"
  value       = var.enable_custom_domain ? "https://${var.domain_name}" : "https://${aws_cloudfront_distribution.website.domain_name}"
}

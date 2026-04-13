output "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.tf_state.id
}

output "state_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.tf_state.arn
}

output "backend_config" {
  description = "Copy this into terraform/main.tf backend block"
  value = <<-EOT
    backend "s3" {
      bucket  = "${aws_s3_bucket.tf_state.id}"
      key     = "website/terraform.tfstate"
      region  = "${var.aws_region}"
      encrypt = true
    }
  EOT
}

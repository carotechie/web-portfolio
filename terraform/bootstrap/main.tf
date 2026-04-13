terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Local backend — intentional for bootstrap.
  # After apply, migrate state to S3 by following the README instructions.
  backend "s3" {
     bucket  = "tf-state-carotechie"
     key     = "bootstrap/terraform.tfstate"
     region  = "us-east-1"
     encrypt = true
  }
}
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "Carolina-Website"
      ManagedBy = "Terraform"
      Purpose   = "TerraformStateBackend"
    }
  }
}

# S3 bucket for Terraform remote state
resource "aws_s3_bucket" "tf_state" {
  bucket = var.state_bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "Terraform State Bucket"
  }
}

# Enable versioning so every state revision is preserved
resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block all public access — state files must never be public
resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Encrypt state at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}



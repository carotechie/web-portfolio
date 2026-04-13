#!/bin/bash

# Carolina Herrera Monteza Website - Update Script
# Quick script to update website files on AWS

set -e

echo "🔄 Updating Carolina's Website on AWS..."
echo ""

# Check if we're in the right directory
if [ ! -f "index.html" ]; then
    echo "❌ Error: index.html not found. Run this script from the project root."
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured. Run: aws configure"
    exit 1
fi

# Navigate to terraform directory to get outputs
cd terraform

# Check if Terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    echo "❌ Terraform state not found. Deploy infrastructure first with: ./deploy-to-aws.sh"
    exit 1
fi

# Get S3 bucket name and CloudFront distribution ID
echo "📊 Getting deployment information..."
BUCKET_NAME=$(terraform output -raw s3_bucket_name 2>/dev/null)
DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id 2>/dev/null)

if [ -z "$BUCKET_NAME" ] || [ -z "$DISTRIBUTION_ID" ]; then
    echo "❌ Failed to get deployment information from Terraform"
    exit 1
fi

echo "S3 Bucket: $BUCKET_NAME"
echo "CloudFront ID: $DISTRIBUTION_ID"
echo ""

# Upload files
echo "📤 Uploading updated files to S3..."
cd ..
aws s3 sync . s3://$BUCKET_NAME/ \
  --exclude "terraform/*" \
  --exclude ".git/*" \
  --exclude ".github/*" \
  --exclude ".vscode/*" \
  --exclude "node_modules/*" \
  --exclude "*.md" \
  --exclude "Dockerfile" \
  --exclude "docker-compose.yml" \
  --exclude ".dockerignore" \
  --exclude "logs/*" \
  --exclude "*.log" \
  --exclude "*.sh" \
  --delete

echo "✅ Files uploaded successfully"
echo ""

# Invalidate CloudFront cache
echo "🔄 Invalidating CloudFront cache..."
INVALIDATION_ID=$(aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/*" \
  --query 'Invalidation.Id' \
  --output text)

echo "Invalidation ID: $INVALIDATION_ID"
echo ""

# Get website URL
WEBSITE_URL=$(cd terraform && terraform output -raw website_url 2>/dev/null)

echo "✅ Website updated successfully!"
echo ""
echo "🌐 Your website: $WEBSITE_URL"
echo ""
echo "⏱️  Changes will be visible in 2-5 minutes after cache invalidation completes"
echo ""

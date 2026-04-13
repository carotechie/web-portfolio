#!/bin/bash

# Carolina Herrera Monteza Website - AWS Deployment Script
# This script automates the deployment process to AWS

set -e

echo "🚀 Carolina's Website - AWS Deployment Script"
echo "=============================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed${NC}"
    echo "   Install: brew install awscli"
    exit 1
fi
echo -e "${GREEN}✅ AWS CLI installed${NC}"

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform is not installed${NC}"
    echo "   Install: brew install terraform"
    exit 1
fi
echo -e "${GREEN}✅ Terraform installed${NC}"

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured${NC}"
    echo "   Run: aws configure"
    exit 1
fi
echo -e "${GREEN}✅ AWS credentials configured${NC}"

AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
echo "   Account: $AWS_ACCOUNT"
echo ""

# Navigate to terraform directory
cd terraform

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}⚠️  terraform.tfvars not found${NC}"
    echo "   Creating from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo -e "${YELLOW}   Please edit terraform.tfvars with your configuration${NC}"
    echo "   Then run this script again."
    exit 1
fi

echo "🔧 Terraform Configuration"
echo "=========================="
echo ""

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init
echo ""

# Validate configuration
echo "✅ Validating configuration..."
terraform validate
echo ""

# Plan deployment
echo "📋 Planning deployment..."
terraform plan -out=tfplan
echo ""

# Ask for confirmation
echo -e "${YELLOW}🤔 Do you want to proceed with deployment?${NC}"
echo "   This will create AWS resources (S3, CloudFront, etc.)"
read -p "   Type 'yes' to continue: " response

if [ "$response" != "yes" ]; then
    echo -e "${RED}❌ Deployment cancelled${NC}"
    rm -f tfplan
    exit 0
fi

# Apply Terraform
echo ""
echo "🚀 Deploying infrastructure..."
terraform apply tfplan
rm -f tfplan
echo ""

# Get outputs
echo "📊 Deployment Information"
echo "========================"
BUCKET_NAME=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "")
DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id 2>/dev/null || echo "")
WEBSITE_URL=$(terraform output -raw website_url 2>/dev/null || echo "")

if [ -z "$BUCKET_NAME" ]; then
    echo -e "${RED}❌ Failed to get deployment outputs${NC}"
    exit 1
fi

echo "S3 Bucket: $BUCKET_NAME"
echo "CloudFront ID: $DISTRIBUTION_ID"
echo "Website URL: $WEBSITE_URL"
echo ""

# Upload website files
echo "📤 Uploading website files..."
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

echo -e "${GREEN}✅ Files uploaded successfully${NC}"
echo ""

# Invalidate CloudFront cache
echo "🔄 Invalidating CloudFront cache..."
INVALIDATION_ID=$(aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/*" \
  --query 'Invalidation.Id' \
  --output text)

echo "Invalidation ID: $INVALIDATION_ID"
echo -e "${GREEN}✅ Cache invalidation created${NC}"
echo ""

# Final summary
echo "🎉 Deployment Complete!"
echo "======================"
echo ""
echo "Your website is now live at:"
echo -e "${GREEN}$WEBSITE_URL${NC}"
echo ""
echo "📝 Next steps:"
echo "   1. Wait 2-5 minutes for CloudFront cache invalidation"
echo "   2. Open your website in a browser"
echo "   3. If using custom domain, configure DNS nameservers"
echo ""
echo "💡 Useful commands:"
echo "   - Update website: ./update-website.sh"
echo "   - View logs: aws cloudfront get-distribution --id $DISTRIBUTION_ID"
echo "   - Monitor costs: aws ce get-cost-and-usage --time-period Start=2026-03-01,End=2026-03-31 --granularity MONTHLY --metrics BlendedCost"
echo ""
echo "📚 For detailed instructions, see: AWS_DEPLOYMENT_GUIDE.md"
echo ""

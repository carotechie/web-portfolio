#!/bin/bash

# Carolina Herrera Monteza Website Deployment Script
# Deploy to Vercel using Terraform

set -e

echo "🚀 Deploying Carolina's Website to Vercel..."

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install Terraform first."
    echo "   Visit: https://www.terraform.io/downloads"
    exit 1
fi

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "❌ terraform.tfvars not found!"
    echo "   Please copy terraform.tfvars.example to terraform.tfvars and fill in your values."
    exit 1
fi

# Check if VERCEL_API_TOKEN is set
if [ -z "$VERCEL_API_TOKEN" ]; then
    echo "⚠️  VERCEL_API_TOKEN environment variable not set."
    echo "   You can set it by running: export VERCEL_API_TOKEN='your-token-here'"
    echo "   Or it should be defined in your terraform.tfvars file."
fi

echo "📋 Initializing Terraform..."
terraform init

echo "📋 Validating configuration..."
terraform validate

echo "📋 Planning deployment..."
terraform plan

echo "🤔 Do you want to proceed with the deployment? (y/N)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "🚀 Deploying website..."
    terraform apply -auto-approve
    
    echo ""
    echo "✅ Deployment completed successfully!"
    echo ""
    echo "🌐 Your website is now live at:"
    terraform output -raw website_url
    echo ""
    echo "🔗 Custom domain (once DNS is configured):"
    terraform output -raw custom_domain_url
    echo ""
    echo "📊 Vercel Dashboard:"
    terraform output -raw vercel_project_dashboard
    echo ""
    echo "🎉 Carolina's professional website is now online!"
else
    echo "❌ Deployment cancelled."
    exit 0
fi
# AWS Deployment Guide - Carolina Herrera Monteza Website

## 🎯 Overview

This guide walks you through deploying your website to AWS using Terraform. The infrastructure uses AWS Free Tier eligible services to minimize costs.

---

## 📋 Part 1: Local Deployment (COMPLETED ✅)

Your website is now running locally!

### Access your local website:
- **URL**: http://localhost
- **Container**: carolina-website
- **Status**: Running and healthy

### Local deployment commands:
```bash
# Start the website
docker-compose up -d --build

# Check status
docker ps | grep carolina

# View logs
docker logs carolina-website

# Stop the website
docker-compose down
```

---

## 🚀 Part 2: AWS Deployment with Terraform

### Prerequisites Checklist

Before deploying to AWS, ensure you have:

- [ ] AWS Account (create at https://aws.amazon.com)
- [ ] AWS CLI installed
- [ ] Terraform installed (>= 1.0)
- [ ] Git configured
- [ ] Domain name (optional, but recommended)

---

## 🔐 Step 1: Configure AWS Credentials

### Option A: Using AWS CLI (Recommended)

1. **Install AWS CLI** (if not already installed):
```bash
# macOS
brew install awscli

# Verify installation
aws --version
```

2. **Create AWS Access Keys**:
   - Go to AWS Console: https://console.aws.amazon.com
   - Navigate to: IAM → Users → Your User → Security Credentials
   - Click "Create access key"
   - Choose "Command Line Interface (CLI)"
   - Download or copy:
     - Access Key ID
     - Secret Access Key

3. **Configure AWS CLI**:
```bash
aws configure
```

You'll be prompted for:
```
AWS Access Key ID: [paste your access key]
AWS Secret Access Key: [paste your secret key]
Default region name: us-east-1
Default output format: json
```

4. **Verify configuration**:
```bash
# Check credentials
aws sts get-caller-identity

# Should return your account info
```

### Option B: Using Environment Variables

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### Option C: Using AWS Profile (for multiple accounts)

```bash
# Configure with profile name
aws configure --profile personal

# Use profile
export AWS_PROFILE=personal
```

---

## 🏗️ Step 2: Prepare Terraform Configuration

### 1. Navigate to terraform directory:
```bash
cd terraform
```

### 2. Create your configuration file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

### 3. Edit `terraform.tfvars`:
```bash
nano terraform.tfvars
# or
code terraform.tfvars
```

### 4. Basic Configuration (No Custom Domain):
```hcl
aws_region           = "us-east-1"
environment          = "production"
domain_name          = "carolina-website-bucket-unique-name"
enable_custom_domain = false
route53_zone_id      = ""
```

**Important**: The `domain_name` will be used as the S3 bucket name, so it must be globally unique!

### 5. Advanced Configuration (With Existing Hosted Zone):

If you already have a Route53 hosted zone for your domain:

```hcl
aws_region           = "us-east-1"
environment          = "production"
domain_name          = "carolinaherreramonteza.com"
enable_custom_domain = true
route53_zone_id      = "Z1234567890ABC"  # Your existing hosted zone ID
acm_certificate_arn  = ""  # We'll create this in Step 3
```

**To find your existing hosted zone ID:**
```bash
aws route53 list-hosted-zones --query "HostedZones[?Name=='carolinaherreramonteza.com.'].Id" --output text
```

### 6. Advanced Configuration (Create New Hosted Zone):

If you don't have a hosted zone yet and want Terraform to create one:

```hcl
aws_region           = "us-east-1"
environment          = "production"
domain_name          = "carolinaherreramonteza.com"
enable_custom_domain = true
route53_zone_id      = ""  # Leave empty to create new zone
acm_certificate_arn  = ""  # We'll create this in Step 3
```

---

## 🔒 Step 3: SSL Certificate (Optional - For Custom Domain)

If using a custom domain, you need an SSL certificate:

### 1. Request certificate in AWS Certificate Manager:
```bash
aws acm request-certificate \
  --domain-name carolinaherreramonteza.com \
  --validation-method DNS \
  --region us-east-1
```

### 2. Get certificate ARN:
```bash
aws acm list-certificates --region us-east-1
```

### 3. Validate certificate:
- Go to AWS Console → Certificate Manager
- Click on your certificate
- Add the DNS validation records to your domain registrar
- Wait for validation (can take 5-30 minutes)

### 4. Update terraform.tfvars with certificate ARN:
```hcl
acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc-123-def"
```

---

## 🚀 Step 4: Deploy Infrastructure with Terraform

### 1. Initialize Terraform:
```bash
cd terraform
terraform init
```

Expected output:
```
Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!
```

### 2. Validate configuration:
```bash
terraform validate
```

### 3. Preview changes:
```bash
terraform plan
```

Review the resources that will be created:
- S3 bucket for website hosting
- CloudFront distribution for CDN
- Route53 hosted zone (if custom domain enabled)
- DNS records (if custom domain enabled)

### 4. Deploy infrastructure:
```bash
terraform apply
```

Type `yes` when prompted.

**Deployment time**: 5-15 minutes (CloudFront takes the longest)

### 5. Save outputs:
```bash
terraform output > ../deployment-info.txt
```

---

## 📤 Step 5: Upload Website Files to S3

### 1. Get S3 bucket name:
```bash
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
echo $BUCKET_NAME
```

### 2. Upload files from project root:
```bash
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
  --exclude "*.log"
```

### 3. Verify upload:
```bash
aws s3 ls s3://$BUCKET_NAME/
```

You should see:
- index.html
- styles.css
- script.js
- images/

---

## 🔄 Step 6: Invalidate CloudFront Cache

After uploading files, clear CloudFront cache:

```bash
cd terraform
DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/*"
```

Wait 2-5 minutes for invalidation to complete.

---

## 🌐 Step 7: Access Your Website

### Get your website URL:
```bash
cd terraform
terraform output website_url
```

### Without custom domain:
Your site will be available at:
```
https://d1234567890abc.cloudfront.net
```

### With custom domain:
After DNS propagation (can take 24-48 hours):
```
https://carolinaherreramonteza.com
```

---

## 🔧 Step 8: Configure Custom Domain DNS (If Applicable)

### 1. Get Route53 nameservers:
```bash
terraform output route53_name_servers
```

### 2. Update your domain registrar:
- Log in to your domain registrar (GoDaddy, Namecheap, etc.)
- Find DNS settings
- Replace nameservers with Route53 nameservers
- Save changes

### 3. Wait for DNS propagation:
```bash
# Check DNS propagation
dig carolinaherreramonteza.com

# Or use online tool
# https://www.whatsmydns.net
```

---

## 📊 Step 9: Verify Deployment

### 1. Check S3 bucket:
```bash
aws s3 ls s3://$(terraform output -raw s3_bucket_name)/
```

### 2. Check CloudFront distribution:
```bash
aws cloudfront get-distribution \
  --id $(terraform output -raw cloudfront_distribution_id) \
  --query 'Distribution.Status'
```

Should return: `"Deployed"`

### 3. Test website:
```bash
curl -I $(terraform output -raw website_url)
```

Should return: `HTTP/2 200`

### 4. Open in browser:
```bash
open $(terraform output -raw website_url)
```

---

## 🔄 Updating Your Website

### Quick update script:
```bash
#!/bin/bash
# update-website.sh

cd terraform

# Upload new files
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
aws s3 sync ../ s3://$BUCKET_NAME/ \
  --exclude "terraform/*" \
  --exclude ".git/*" \
  --exclude "*.md" \
  --delete

# Invalidate cache
DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/*"

echo "✅ Website updated successfully!"
```

Make it executable:
```bash
chmod +x update-website.sh
./update-website.sh
```

---

## 💰 Cost Estimation

### Free Tier (First 12 months):
- S3: 5GB storage, 20,000 GET requests
- CloudFront: 1TB data transfer out
- Route53: $0.50/month per hosted zone

### After Free Tier:
- S3: ~$0.023 per GB/month
- CloudFront: ~$0.085 per GB (first 10TB)
- Route53: $0.50/month + $0.40 per million queries
- **Estimated**: $2-5/month for low traffic

### Monitor costs:
```bash
# View current month costs
aws ce get-cost-and-usage \
  --time-period Start=2026-03-01,End=2026-03-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=SERVICE
```

---

## 🛠️ Troubleshooting

### Issue: "Access Denied" when accessing website
**Solution**:
```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket YOUR_BUCKET_NAME

# Reapply Terraform
terraform apply -auto-approve
```

### Issue: CloudFront shows old content
**Solution**:
```bash
# Create invalidation
aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/*"
```

### Issue: Certificate validation stuck
**Solution**:
- Check DNS records in your domain registrar
- Ensure CNAME records match AWS Certificate Manager
- Wait up to 30 minutes

### Issue: "Bucket name already exists"
**Solution**:
- S3 bucket names are globally unique
- Change `domain_name` in terraform.tfvars
- Use format: `carolina-website-YOUR_INITIALS-2026`

---

## 🗑️ Cleanup / Destroy Infrastructure

### To remove all AWS resources:
```bash
cd terraform

# Preview what will be destroyed
terraform plan -destroy

# Destroy infrastructure
terraform destroy
```

Type `yes` when prompted.

**Warning**: This will permanently delete:
- S3 bucket and all files
- CloudFront distribution
- Route53 hosted zone and records

---

## 📚 Useful Commands Reference

```bash
# Terraform
terraform init              # Initialize
terraform plan              # Preview changes
terraform apply             # Deploy
terraform destroy           # Remove all resources
terraform output            # Show outputs
terraform fmt               # Format code
terraform validate          # Validate syntax

# AWS S3
aws s3 ls s3://BUCKET/                    # List files
aws s3 sync . s3://BUCKET/                # Upload files
aws s3 rm s3://BUCKET/file.html           # Delete file
aws s3 rb s3://BUCKET --force             # Delete bucket

# AWS CloudFront
aws cloudfront list-distributions         # List distributions
aws cloudfront create-invalidation        # Clear cache
aws cloudfront get-distribution           # Get details

# AWS Route53
aws route53 list-hosted-zones             # List zones
aws route53 list-resource-record-sets     # List DNS records

# AWS ACM
aws acm list-certificates --region us-east-1    # List certificates
aws acm describe-certificate --certificate-arn ARN  # Get details
```

---

## 🎉 Success Checklist

- [ ] AWS credentials configured
- [ ] Terraform initialized
- [ ] Infrastructure deployed
- [ ] Website files uploaded to S3
- [ ] CloudFront cache invalidated
- [ ] Website accessible via CloudFront URL
- [ ] (Optional) Custom domain configured
- [ ] (Optional) SSL certificate validated
- [ ] (Optional) DNS propagated

---

## 📞 Support

If you encounter issues:

1. Check AWS CloudWatch logs
2. Review Terraform state: `terraform show`
3. Check AWS Console for resource status
4. Review this guide's troubleshooting section

---

## 🔗 Additional Resources

- [AWS Free Tier](https://aws.amazon.com/free/)
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [Route53 Documentation](https://docs.aws.amazon.com/route53/)

---

**Created**: March 2026  
**Author**: Carolina Herrera Monteza  
**Version**: 1.0

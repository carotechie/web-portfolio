# GitHub Actions Setup Guide

This guide will help you set up GitHub Actions for automated deployment of your website to AWS.

## 📋 Prerequisites

1. AWS Account with appropriate permissions
2. GitHub repository for your website
3. AWS IAM user with programmatic access

## 🔐 Step 1: Create AWS IAM User

### 1.1 Create IAM User

```bash
aws iam create-user --user-name github-actions-deployer
```

### 1.2 Create IAM Policy

Create a file `github-actions-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "cloudfront:*",
        "route53:*",
        "acm:*",
        "iam:GetRole",
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
```

Apply the policy:

```bash
aws iam create-policy \
  --policy-name GitHubActionsDeployPolicy \
  --policy-document file://github-actions-policy.json

# Attach policy to user
aws iam attach-user-policy \
  --user-name github-actions-deployer \
  --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/GitHubActionsDeployPolicy
```

### 1.3 Create Access Keys

```bash
aws iam create-access-key --user-name github-actions-deployer
```

**Save the output!** You'll need:
- `AccessKeyId`
- `SecretAccessKey`

## 🔑 Step 2: Configure GitHub Secrets

### 2.1 Navigate to Repository Settings

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

### 2.2 Add Required Secrets

Add the following secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `AWS_ACCESS_KEY_ID` | Your AWS Access Key ID | From IAM user creation |
| `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Access Key | From IAM user creation |

### 2.3 (Optional) Add Environment Variables

If you want to override default values, add these as **Variables**:

| Variable Name | Example Value | Description |
|---------------|---------------|-------------|
| `AWS_REGION` | `us-east-1` | AWS region for deployment |
| `TERRAFORM_VERSION` | `1.6.0` | Terraform version to use |

## 🚀 Step 3: Initialize Terraform State (First Time Only)

### Option A: Local State (Simple)

No additional setup needed. State will be stored in the repository (not recommended for production).

### Option B: Remote State (Recommended)

1. **Create S3 bucket for state**:
```bash
aws s3 mb s3://carolina-terraform-state --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket carolina-terraform-state \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket carolina-terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

2. **Create DynamoDB table for locking**:
```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

3. **Uncomment backend configuration** in `terraform/main.tf`:
```hcl
backend "s3" {
  bucket         = "carolina-terraform-state"
  key            = "website/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-state-lock"
  encrypt        = true
}
```

4. **Initialize locally first**:
```bash
cd terraform
terraform init
terraform apply
```

## 🔄 Step 4: Test the Workflow

### 4.1 Manual Trigger

1. Go to **Actions** tab in GitHub
2. Select **Deploy Website to AWS**
3. Click **Run workflow**
4. Select branch and click **Run workflow**

### 4.2 Automatic Trigger

Push to main branch:
```bash
git add .
git commit -m "Initial deployment setup"
git push origin main
```

## 📊 Step 5: Monitor Deployment

### 5.1 GitHub Actions

1. Go to **Actions** tab
2. Click on the running workflow
3. Monitor each job:
   - **Terraform Plan & Apply**: Infrastructure changes
   - **Deploy Website Files**: File upload to S3
   - **Notify Deployment Status**: Final status

### 5.2 AWS Console

Monitor in AWS Console:
- **S3**: Check bucket contents
- **CloudFront**: Check distribution status
- **CloudWatch**: View logs and metrics

## 🔍 Troubleshooting

### Issue: "Error: No valid credential sources found"

**Solution**: Check GitHub secrets are correctly set:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### Issue: "Error: AccessDenied"

**Solution**: Verify IAM user has correct permissions:
```bash
aws iam list-attached-user-policies --user-name github-actions-deployer
```

### Issue: "Error: Backend initialization required"

**Solution**: Initialize Terraform state:
```bash
cd terraform
terraform init
```

### Issue: Workflow fails on PR

**Solution**: This is expected. The workflow only applies changes on push to main. PRs only run plan.

## 🔒 Security Best Practices

1. **Never commit secrets** to the repository
2. **Use least privilege** IAM policies
3. **Enable MFA** on AWS account
4. **Rotate access keys** regularly
5. **Monitor CloudTrail** for suspicious activity
6. **Use branch protection** rules
7. **Review PR changes** before merging

## 📝 Workflow Behavior

### On Pull Request
- ✅ Terraform format check
- ✅ Terraform init
- ✅ Terraform validate
- ✅ Terraform plan
- ✅ Comment plan on PR
- ❌ No apply or deployment

### On Push to Main
- ✅ Terraform format check
- ✅ Terraform init
- ✅ Terraform validate
- ✅ Terraform plan
- ✅ **Terraform apply**
- ✅ **Upload files to S3**
- ✅ **Invalidate CloudFront cache**
- ✅ Deployment notification

### Manual Trigger
- Same as push to main
- Can be triggered from any branch

## 🎯 Next Steps

After successful deployment:

1. **Get website URL**:
```bash
cd terraform
terraform output website_url
```

2. **Set up custom domain** (optional):
   - Request ACM certificate
   - Update `terraform.tfvars`
   - Push changes to trigger deployment

3. **Monitor costs**:
   - Set up AWS billing alerts
   - Review Cost Explorer regularly

4. **Set up monitoring**:
   - CloudWatch alarms
   - CloudFront metrics
   - S3 metrics

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Free Tier](https://aws.amazon.com/free/)

## 🤝 Support

For issues or questions:
- Check workflow logs in GitHub Actions
- Review AWS CloudWatch logs
- Verify IAM permissions
- Contact: Carolina Herrera Monteza

---

**Last Updated**: February 2026
**Maintained By**: Carolina Herrera Monteza

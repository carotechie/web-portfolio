# Terraform — AWS Infrastructure

Deploys the Carolina Herrera Monteza website using **S3 + CloudFront + Route53**.

## Architecture

| Resource | Purpose |
|----------|---------|
| S3 bucket | Static website hosting |
| CloudFront | Global CDN, HTTPS, caching |
| ACM certificate | Free SSL for custom domain |
| Route53 records | DNS alias to CloudFront (uses existing hosted zone) |

---

## First time? Start with bootstrap

Before deploying the website infrastructure, you need to create the S3 state bucket first.

Follow all steps in [`bootstrap/README.md`](bootstrap/README.md) — it covers:
- Setting AWS credentials as environment variables
- Creating the `tf-state-carotechie` bucket
- Migrating local state to S3
- Enabling the S3 backend in `main.tf`

Come back here once bootstrap is complete.

---

## Deploy

```bash
cd terraform

# 1. Copy and edit vars
cp terraform.tfvars.example terraform.tfvars

# 2. Init — connects to the S3 backend created in bootstrap
terraform init

# 3. Preview
terraform plan

# 4. Deploy
terraform apply
```

---

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-1` | AWS region |
| `environment` | `production` | Environment tag |
| `domain_name` | `tech.carolinaherreramonteza.com` | Domain / S3 bucket name |
| `enable_custom_domain` | `false` | Enable Route53 + ACM |
| `acm_certificate_arn` | `""` | ACM cert ARN (us-east-1) |
| `route53_zone_id` | `""` | Existing hosted zone ID |

---

## Custom domain setup

1. Request a certificate in ACM (must be `us-east-1`):
```bash
aws acm request-certificate \
  --domain-name tech.carolinaherreramonteza.com \
  --validation-method DNS \
  --region us-east-1
```

2. Validate it via DNS (add the CNAME record ACM gives you to your registrar)

3. Update `terraform.tfvars`:
```hcl
enable_custom_domain = true
acm_certificate_arn  = "arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/CERT_ID"
route53_zone_id      = "Z1234567890ABC"  # your existing hosted zone
```

4. Re-apply:
```bash
terraform apply
```

---

## Upload website files

```bash
BUCKET=$(terraform output -raw s3_bucket_name)

aws s3 sync ../ s3://$BUCKET/ \
  --exclude "terraform/*" \
  --exclude ".git/*" \
  --exclude ".github/*" \
  --exclude "*.md" \
  --exclude "Dockerfile" \
  --exclude "docker-compose.yml" \
  --exclude "logs/*"
```

## Invalidate CloudFront cache

```bash
DIST=$(terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation --distribution-id $DIST --paths "/*"
```

---

## Outputs

| Output | Description |
|--------|-------------|
| `website_url` | Live URL (CloudFront or custom domain) |
| `cloudfront_url` | CloudFront default URL |
| `cloudfront_distribution_id` | For cache invalidation |
| `s3_bucket_name` | Bucket name for file uploads |
| `route53_zone_id` | Zone ID used |

---

## IAM permissions required

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket", "s3:DeleteBucket", "s3:GetBucketPolicy",
        "s3:PutBucketPolicy", "s3:DeleteBucketPolicy", "s3:GetBucketWebsite",
        "s3:PutBucketWebsite", "s3:GetBucketPublicAccessBlock",
        "s3:PutBucketPublicAccessBlock", "s3:GetBucketTagging",
        "s3:PutBucketTagging", "s3:ListBucket", "s3:GetObject",
        "s3:PutObject", "s3:DeleteObject", "s3:GetBucketLocation",
        "s3:GetBucketVersioning", "s3:PutBucketVersioning",
        "s3:GetEncryptionConfiguration", "s3:PutEncryptionConfiguration"
      ],
      "Resource": [
        "arn:aws:s3:::tech.carolinaherreramonteza.com",
        "arn:aws:s3:::tech.carolinaherreramonteza.com/*",
        "arn:aws:s3:::tf-state-carotechie",
        "arn:aws:s3:::tf-state-carotechie/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateDistribution", "cloudfront:UpdateDistribution",
        "cloudfront:DeleteDistribution", "cloudfront:GetDistribution",
        "cloudfront:GetDistributionConfig", "cloudfront:ListDistributions",
        "cloudfront:CreateInvalidation", "cloudfront:GetInvalidation",
        "cloudfront:CreateOriginAccessIdentity",
        "cloudfront:DeleteOriginAccessIdentity",
        "cloudfront:GetOriginAccessIdentity",
        "cloudfront:TagResource", "cloudfront:ListTagsForResource"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:GetHostedZone", "route53:ListHostedZones",
        "route53:ListHostedZonesByName", "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets", "route53:GetChange"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "acm:RequestCertificate", "acm:DescribeCertificate",
        "acm:DeleteCertificate", "acm:ListCertificates",
        "acm:AddTagsToCertificate", "acm:ListTagsForCertificate"
      ],
      "Resource": "*"
    }
  ]
}
```

## Destroy

```bash
terraform destroy
```

Note: the bootstrap resource (`tf-state-carotechie` bucket) has `prevent_destroy = true` and must be removed manually if needed.

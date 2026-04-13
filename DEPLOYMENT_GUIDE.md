# Deployment Guide

This guide covers everything needed to run the website locally and deploy it to AWS — first time and ongoing updates.

---

## Scripts overview

| Script | Purpose |
|--------|---------|
| `./run-local.sh` | Builds and starts the website locally via Docker at http://localhost |
| `./deploy-to-aws.sh` | First-time full AWS deployment — creates all infrastructure and uploads files |
| `./update-website.sh` | Subsequent updates — syncs changed files to S3 and invalidates CloudFront cache |

---

## Running locally

Make sure Docker Desktop is running, then:

```bash
./run-local.sh
```

Open http://localhost in your browser.

To stop it:
```bash
docker-compose down
```

---

## Deploying to AWS — First time

Follow these steps in order the very first time.

### Step 1 — Set AWS credentials

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"

# Verify
aws sts get-caller-identity --output json
```

### Step 2 — Create the Terraform state bucket

The state bucket must exist before deploying the main infrastructure.
Follow all steps in [`terraform/bootstrap/README.md`](terraform/bootstrap/README.md).

This creates the `tf-state-carotechie` S3 bucket and attaches the IAM policy to your deployment user (`web-caro`).

### Step 3 — Request an ACM certificate

The certificate must be in `us-east-1` regardless of where your site is hosted.

```bash
aws acm request-certificate \
  --domain-name tech.carolinaherreramonteza.com \
  --validation-method DNS \
  --region us-east-1
```

Get the certificate ARN:
```bash
aws acm list-certificates --region us-east-1 --output json
```

Validate it — go to ACM in the AWS Console, open the certificate, and click "Create records in Route53". Status changes to "Issued" within ~5 minutes.

Confirm it's issued:
```bash
aws acm describe-certificate \
  --certificate-arn YOUR_CERT_ARN \
  --region us-east-1 \
  --query "Certificate.Status" \
  --output text
```

### Step 4 — Configure Terraform variables

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit `terraform/terraform.tfvars`:

```hcl
aws_region           = "us-east-1"
environment          = "production"
domain_name          = "tech.carolinaherreramonteza.com"
enable_custom_domain = true
acm_certificate_arn  = "arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/CERT_ID"
route53_zone_id      = "YOUR_EXISTING_ZONE_ID"
```

Find your hosted zone ID:
```bash
aws route53 list-hosted-zones \
  --query "HostedZones[?Name=='carolinaherreramonteza.com.'].Id" \
  --output text
```

### Step 5 — Enable the S3 backend in main.tf

In `terraform/main.tf`, uncomment the backend block:

```hcl
backend "s3" {
  bucket  = "tf-state-carotechie"
  key     = "website/terraform.tfstate"
  region  = "us-east-1"
  encrypt = true
}
```

Then init Terraform to connect to the remote backend:

```bash
cd terraform
terraform init
```

### Step 6 — Deploy

```bash
./deploy-to-aws.sh
```

The script will:
1. Validate prerequisites (AWS CLI, Terraform, credentials)
2. Run `terraform plan` and show what will be created
3. Ask for confirmation before applying
4. Create all AWS resources (S3, CloudFront, Route53 records)
5. Upload website files to S3
6. Invalidate CloudFront cache
7. Print the live URL

Deployment takes 10–15 minutes (CloudFront provisioning is the slowest part).

---

## Deploying updates — Subsequent times

After the infrastructure exists, just run:

```bash
./update-website.sh
```

This syncs only the website files (HTML, CSS, JS, images) to S3 and clears the CloudFront cache. Changes are live in 2–5 minutes.

---

## Troubleshooting

**ACM certificate stuck in "Pending validation"**
- Go to ACM Console → your certificate → "Create records in Route53"
- Verify the CNAME record exists: `dig CNAME _abc123.tech.carolinaherreramonteza.com`
- Make sure the certificate was created in `us-east-1`

**Website shows old content**
```bash
./update-website.sh
```

**Access Denied on S3**
```bash
cd terraform
terraform apply -auto-approve
```

**Terraform state not found when running update-website.sh**
- The infrastructure hasn't been deployed yet — run `./deploy-to-aws.sh` first

**CloudFront distribution still deploying**
```bash
aws cloudfront get-distribution \
  --id $(cd terraform && terraform output -raw cloudfront_distribution_id) \
  --query 'Distribution.Status' \
  --output text
```
Wait until it returns `Deployed`.

---

## Cost estimate

| Service | Free tier | After free tier |
|---------|-----------|-----------------|
| S3 | 5GB / 20k requests | ~$0.023/GB |
| CloudFront | 1TB transfer/month | ~$0.085/GB |
| Route53 | — | $0.50/month per zone |
| ACM | Free | Free |

Expected cost for a personal portfolio: ~$0.50–2/month.

# Part 2 — Deploy to AWS (50 min)

In this part you'll deploy your website to AWS using Terraform. By the end it will be live on a public URL.

The optional last section covers connecting a custom domain with HTTPS.

---

## Step 1 — Set AWS credentials (5 min)

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
```

Verify it works:

```bash
aws sts get-caller-identity --output json
```

You should see your account ID and user ARN returned.

---

## Step 2 — Create the Terraform state bucket (10 min)

Terraform needs an S3 bucket to store its state before it can create anything else. This is a one-time setup.

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

Type `yes` when prompted. This creates the `tf-state-carotechie` bucket.

Now attach the IAM policy to your deployment user so it has permission to create all the website resources:

```bash
export IAM_USERNAME="your-iam-username"

aws iam put-user-policy \
  --user-name $IAM_USERNAME \
  --policy-name CarolinaWebsitePolicy \
  --policy-document file://policy.json
```

Then migrate the bootstrap state to S3. In `terraform/bootstrap/main.tf`, comment out `backend "local" {}` and uncomment the `backend "s3"` block, then:

```bash
terraform init -migrate-state
```

Type `yes` to migrate. Full details in [terraform/bootstrap/README.md](terraform/bootstrap/README.md).

---

## Step 3 — Configure Terraform variables (5 min)

```bash
cd ../..
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit `terraform/terraform.tfvars` — at minimum set your domain name as the S3 bucket name:

```hcl
aws_region           = "us-east-1"
environment          = "production"
domain_name          = "your-unique-bucket-name"  # used as S3 bucket name — must be globally unique
enable_custom_domain = false                        # set true only if you have a domain + cert ready
```

---

## Step 4 — Enable the S3 backend in main.tf (2 min)

In `terraform/main.tf`, comment out `backend "local" {}` and uncomment the `backend "s3"` block:

```hcl
backend "s3" {
  bucket  = "tf-state-carotechie"
  key     = "website/terraform.tfstate"
  region  = "us-east-1"
  encrypt = true
}
```

Then init:

```bash
cd terraform
terraform init
```

---

## Step 5 — Deploy (15 min)

```bash
cd ..
./deploy-to-aws.sh
```

The script will show you a plan and ask for confirmation before creating anything. Type `yes`.

It will create:
- S3 bucket for your website files
- CloudFront distribution (global CDN + HTTPS)
- Route53 DNS records (if custom domain enabled)

Deployment takes 10–15 minutes. CloudFront provisioning is the slowest part.

At the end you'll get a URL like:
```
https://d1234567890abc.cloudfront.net
```

Open it — your website is live.

---

## Step 6 — Verify (3 min)

```bash
# Check CloudFront is deployed
aws cloudfront get-distribution \
  --id $(cd terraform && terraform output -raw cloudfront_distribution_id) \
  --query 'Distribution.Status' \
  --output text
# Should return: Deployed

# Test the URL
curl -I $(cd terraform && terraform output -raw website_url)
# Should return: HTTP/2 200
```

---

## Checkpoint

- [ ] `terraform apply` completed successfully
- [ ] Website is accessible via CloudFront URL
- [ ] Your name and content appear correctly
- [ ] HTTPS works

---

## Optional — Custom domain with HTTPS (10 min)

Only do this if you have a domain ready. There are 3 ways to set it up depending on where your domain is:

- No domain yet → buy one in Route53
- Domain at GoDaddy, Namecheap, etc. → move DNS to Route53
- Keep domain at your registrar → just point a CNAME to CloudFront

Full step-by-step for all 3 scenarios: [WORKSHOP_CUSTOM_DOMAIN.md](WORKSHOP_CUSTOM_DOMAIN.md)

Once your certificate is issued and `terraform.tfvars` is updated with `enable_custom_domain = true`, `acm_certificate_arn`, and `route53_zone_id`, re-run:

```bash
./deploy-to-aws.sh
```

---

## Updating your website later

Any time you make changes, just run:

```bash
./update-website.sh
```

Files sync to S3 and CloudFront cache clears automatically. Changes are live in 2–5 minutes.

---

## Troubleshooting

**Certificate stuck in "Pending validation"**
- Click "Create records in Route53" in the ACM Console
- Run `dig CNAME _validation-record.your.domain.com` to confirm the record exists
- Make sure the cert was created in `us-east-1`

**Website shows old content after update**
```bash
./update-website.sh
```

**Access Denied on S3**
```bash
cd terraform && terraform apply -auto-approve
```

**CloudFront still deploying**
- Wait a few more minutes and check again with `terraform output website_url`

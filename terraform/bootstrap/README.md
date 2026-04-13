# Bootstrap — Terraform State Backend

This folder creates the S3 bucket used as the remote backend for the main Terraform configuration.

It uses a **local backend** intentionally — you can't store state in a bucket that doesn't exist yet.

## Resources created

| Resource | Name |
|----------|------|
| S3 bucket | `tf-state-carotechie` |
| S3 versioning | enabled |
| S3 encryption | AES256 |
| S3 public access | fully blocked |

---

## Step 1 — Set AWS credentials

Export your IAM user credentials before running any Terraform commands:

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
```

Verify they work:

```bash
aws sts get-caller-identity
```

---

## Step 2 — Deploy the bootstrap (local state)

```bash
cd terraform/bootstrap

terraform init
terraform plan
terraform apply
```

State is stored locally in `terraform.tfstate` inside this folder.

---

## Step 3 — Migrate bootstrap state to S3 (optional but recommended)

Once the bucket exists, you can store the bootstrap state in it too:

```bash
# 1. In bootstrap/main.tf, replace backend "local" {} with:
#
#   backend "s3" {
#     bucket  = "tf-state-carotechie"
#     key     = "bootstrap/terraform.tfstate"
#     region  = "us-east-1"
#     encrypt = true
#   }

# 2. Re-init — Terraform will ask to migrate local state to S3
terraform init -migrate-state
```

---

## Step 4 — Enable S3 backend in the main config

In `terraform/main.tf`, uncomment and fill in the backend block:

```hcl
backend "s3" {
  bucket  = "tf-state-carotechie"
  key     = "website/terraform.tfstate"
  region  = "us-east-1"
  encrypt = true
}
```

Then re-init the main config:

```bash
cd terraform
terraform init
```

Terraform will detect the new backend and offer to migrate any existing local state to S3. Type `yes`.

---
## Step 5 — Attach the new IAM policy to your deployment user

Set your IAM username as an environment variable:

Go to your root account
Go to IAM -> Users -> enter to your user
Click on Permissions -> Add Permissions -> Add Inline policy
Paste it and edit your website name ( as it will be used for creating your domain in route53 and the page bucket) and the Terraform bucket


---

## Notes

- The `prevent_destroy = true` lifecycle rule protects the bucket from accidental `terraform destroy`
- Never delete the state bucket manually — you'll lose track of all managed resources

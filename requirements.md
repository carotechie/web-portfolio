# Requirements

Everything you need to run this website locally and deploy it to AWS.

---

## Local Development

| Tool | Version | Install |
|------|---------|---------|
| Docker Desktop | Latest | https://www.docker.com/products/docker-desktop |
| Git | Latest | https://git-scm.com/downloads |
| Kiro IDE | Latest | https://kiro.dev |

### Run locally

```bash
./run-local.sh
```

Website available at http://localhost

---

## AWS Deployment

| Tool | Version | Install |
|------|---------|---------|
| Terraform | >= 1.0 | https://developer.hashicorp.com/terraform/install |
| AWS CLI | >= 2.0 | https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html |

### First time setup

1. Follow `terraform/bootstrap/README.md` to create the state bucket and attach IAM policies
2. Follow `terraform/README.md` to deploy the website infrastructure

---

## AWS Account

- An AWS account is required — https://aws.amazon.com/free
- Create a dedicated IAM user (do not use root) — see `terraform/bootstrap/policy.json` for the required permissions
- Domain registered and hosted zone in Route53 for `tech.carolinaherreramonteza.com`
- ACM certificate requested in `us-east-1` region

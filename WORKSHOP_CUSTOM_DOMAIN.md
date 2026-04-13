# Custom Domain Setup Guide

This guide covers all the ways to get a custom domain working with your website on AWS.

There are 3 scenarios — pick the one that matches your situation:

- [Scenario A](#scenario-a--buy-a-domain-directly-in-aws-route53) — You don't have a domain yet → buy it in Route53
- [Scenario B](#scenario-b--you-have-a-domain-at-another-registrar) — You have a domain at GoDaddy, Namecheap, Google Domains, etc. → move DNS to Route53
- [Scenario C](#scenario-c--keep-your-domain-at-your-current-registrar) — You want to keep your domain where it is → just point it to CloudFront

---

## Scenario A — Buy a domain directly in AWS Route53

The simplest option. Everything stays in AWS.

### Register the domain

```bash
# Check if your domain is available
aws route53domains check-domain-availability \
  --domain-name your-domain.com \
  --region us-east-1 \
  --output json

# Register it (this charges your AWS account)
aws route53domains register-domain \
  --domain-name your-domain.com \
  --duration-in-years 1 \
  --admin-contact file://contact.json \
  --registrant-contact file://contact.json \
  --tech-contact file://contact.json \
  --privacy-protect-admin-contact \
  --privacy-protect-registrant-contact \
  --privacy-protect-tech-contact \
  --region us-east-1
```

For the contact.json file, create it with your details:

```json
{
  "FirstName": "Your",
  "LastName": "Name",
  "ContactType": "PERSON",
  "OrganizationName": "",
  "AddressLine1": "Your Address",
  "City": "Your City",
  "CountryCode": "US",
  "ZipCode": "00000",
  "PhoneNumber": "+1.5555555555",
  "Email": "your@email.com"
}
```

Or register directly in the AWS Console:
- Go to Route53 → Domains → Register domain
- Search for your domain, add to cart, fill in contact details, purchase

Registration takes 5–15 minutes. AWS automatically creates a hosted zone for you.

### Get your hosted zone ID

```bash
aws route53 list-hosted-zones --output json \
  --query "HostedZones[?Name=='your-domain.com.'].Id" \
  --output text
# Returns something like: /hostedzone/Z1234567890ABC
# Use only the last part: Z1234567890ABC
```

Now skip to [Request ACM Certificate](#request-an-acm-certificate).

---

## Scenario B — You have a domain at another registrar

You'll transfer DNS management to Route53 (not the domain registration itself — just the nameservers). This is free and takes about 5 minutes to set up, plus up to 48 hours for propagation.

### Create a hosted zone in Route53

```bash
aws route53 create-hosted-zone \
  --name your-domain.com \
  --caller-reference "$(date +%s)" \
  --output json
```

Note the 4 nameservers in the output — they look like:
```
ns-123.awsdns-45.com
ns-678.awsdns-90.net
ns-111.awsdns-22.org
ns-999.awsdns-00.co.uk
```

Or create it in the Console: Route53 → Hosted zones → Create hosted zone.

### Update nameservers at your registrar

Log in to your domain registrar and find the DNS / Nameserver settings. Replace the existing nameservers with the 4 Route53 nameservers above.

Common registrar guides:
- GoDaddy: My Products → DNS → Nameservers → Change → Enter my own nameservers
- Namecheap: Domain List → Manage → Nameservers → Custom DNS
- Google Domains / Squarespace: DNS → Nameservers → Custom
- Cloudflare: Remove the site from Cloudflare, then update at your registrar

### Verify propagation

```bash
# Check which nameservers are responding for your domain
dig NS your-domain.com

# Or use an online tool
# https://www.whatsmydns.net/#NS/your-domain.com
```

Once the Route53 nameservers appear, DNS is delegated. This can take anywhere from a few minutes to 48 hours depending on your registrar.

### Get your hosted zone ID

```bash
aws route53 list-hosted-zones --output json \
  --query "HostedZones[?Name=='your-domain.com.'].Id" \
  --output text
```

Now continue to [Request ACM Certificate](#request-an-acm-certificate).

---

## Scenario C — Keep your domain at your current registrar

You don't need to move anything. You'll just add a CNAME record pointing to your CloudFront distribution.

Skip the hosted zone setup. After deploying with Terraform (with `enable_custom_domain = false`), get your CloudFront domain:

```bash
cd terraform
terraform output cloudfront_domain_name
# Returns: d1234567890abc.cloudfront.net
```

Go to your registrar's DNS settings and add:

| Type | Name | Value |
|------|------|-------|
| CNAME | `tech` (or `@` for root) | `d1234567890abc.cloudfront.net` |

Note: most registrars don't support CNAME on the root domain (`@`). If you need the root domain, use Scenario A or B instead, or use a subdomain like `tech.yourdomain.com`.

You won't need `route53_zone_id` in your tfvars for this scenario. SSL still works via ACM — continue to [Request ACM Certificate](#request-an-acm-certificate).

---

## Request an ACM Certificate

Regardless of which scenario you chose, the certificate must be in `us-east-1` for CloudFront.

```bash
aws acm request-certificate \
  --domain-name your-domain.com \
  --validation-method DNS \
  --region us-east-1 \
  --output json
```

Get the certificate ARN:

```bash
aws acm list-certificates \
  --region us-east-1 \
  --output json \
  --query "CertificateSummaryList[?DomainName=='your-domain.com'].CertificateArn" \
  --output text
```

### Validate the certificate

ACM needs to verify you own the domain by checking a CNAME record.

**If your domain is in Route53 (Scenario A or B):**
Go to ACM Console → your certificate → click "Create records in Route53". Done in one click.

**If your domain is at another registrar (Scenario C):**
Get the validation CNAME details:

```bash
aws acm describe-certificate \
  --certificate-arn YOUR_CERT_ARN \
  --region us-east-1 \
  --query "Certificate.DomainValidationOptions[0].ResourceRecord" \
  --output json
```

Add that CNAME record manually at your registrar.

Check validation status:

```bash
aws acm describe-certificate \
  --certificate-arn YOUR_CERT_ARN \
  --region us-east-1 \
  --query "Certificate.Status" \
  --output text
# Wait until it returns: ISSUED
```

---

## Update terraform.tfvars

Once the certificate is issued, update your variables:

```hcl
enable_custom_domain = true
domain_name          = "your-domain.com"
acm_certificate_arn  = "arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/CERT_ID"

# Only needed for Scenario A or B (domain in Route53)
route53_zone_id      = "Z1234567890ABC"

# Leave empty for Scenario C (domain at external registrar)
# route53_zone_id    = ""
```

Then re-deploy:

```bash
./deploy-to-aws.sh
```

---

## Verify your custom domain

```bash
# Check DNS is resolving
dig your-domain.com

# Test HTTPS
curl -I https://your-domain.com
# Should return: HTTP/2 200
```

Or check propagation globally: https://www.whatsmydns.net

---

## Troubleshooting

**Certificate stuck in "Pending validation" after 30 min**
- Confirm the CNAME validation record exists in DNS: `dig CNAME _abc123.your-domain.com`
- Make sure the cert was requested in `us-east-1` — certificates in other regions won't work with CloudFront
- If the record is there, just wait — it can take up to 30 minutes

**CloudFront returning 403 after adding custom domain**
- Make sure `enable_custom_domain = true` and `acm_certificate_arn` is set in tfvars
- Re-run `terraform apply`

**Domain not resolving after nameserver change**
- DNS propagation can take up to 48 hours
- Check current nameservers: `dig NS your-domain.com`
- Use https://www.whatsmydns.net to check from multiple locations

**CNAME not working on root domain**
- Root domains (`@`) can't use CNAME records — use a subdomain like `www` or `tech`
- Or move to Route53 which supports ALIAS records on root domains (Scenario A or B)

# Build Your Own Portfolio Website — Workshop

Welcome! This is a 2-part hands-on workshop where you'll build and deploy your own personal portfolio website, using this site as a template.

By the end you'll have a live website on AWS with your own resume, skills, and experience — customized to look like yours.

---

## Before the workshop

Install everything listed in [requirements.md](requirements.md) before you show up. The workshop won't have time for installs.

---

## Workshop parts

### Part 1 — Build your website locally (40 min)
[WORKSHOP_PART1_LOCAL.md](WORKSHOP_PART1_LOCAL.md)

Clone the repo, run it locally, and use Kiro to personalize it with your own details — name, experience, skills, colors, and more.

### Part 2 — Deploy to AWS (50 min)
[WORKSHOP_PART2_AWS.md](WORKSHOP_PART2_AWS.md)

Deploy your website to AWS using Terraform. Covers the state bucket bootstrap, infrastructure deploy, file upload, and optionally connecting a custom domain with HTTPS.

- [Custom Domain Setup Guide](WORKSHOP_CUSTOM_DOMAIN.md) — buy a domain in AWS, move from another registrar, or keep it where it is

---

## Reference docs

- [Deployment Guide](DEPLOYMENT_GUIDE.md) — full deploy reference for first time and updates
- [Terraform README](terraform/README.md) — infrastructure details and IAM permissions
- [Bootstrap README](terraform/bootstrap/README.md) — state bucket setup

---

## Tech stack

- HTML5, CSS3, Vanilla JavaScript
- Nginx + Docker
- AWS S3 + CloudFront + Route53 + ACM
- Terraform

## License

© 2026 Carolina Herrera Monteza. All rights reserved.

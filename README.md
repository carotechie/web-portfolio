# Carolina Herrera Monteza — Personal Website

Personal portfolio website for Carolina Herrera Monteza, Senior DevOps Engineer with 11+ years of experience. Built with HTML, CSS, and JavaScript, served via Nginx on Docker, and deployed to AWS using Terraform.

---

## Docs

Follow these in order:

1. [Requirements](requirements.md) — tools and accounts you need before anything else
2. [Run Locally](QUICK_START.md) — get the site running on your machine with Docker
3. [Deployment Guide](DEPLOYMENT_GUIDE.md) — run locally, first-time AWS deploy, and ongoing updates

---

## Want to build your own version?

Use the Kiro prompt below to generate a personalized version of this website for yourself — just swap in your own details.

---

### Kiro Prompt

```
I want to build a personal portfolio website similar to this one. Help me customize it with my own details.

Here is what I want to change:

**Personal info:**
- Name: [Your Full Name]
- Title: [Your Job Title]
- Years of experience: [X]
- Bio: [2-3 sentences about yourself]
- LinkedIn: [your LinkedIn URL]
- GitHub: [your GitHub URL]
- Blog: [your blog URL, or remove if none]

**Experience:**
[List each role like this]
- [Year range] | [Job Title] | [Company / Client]
  Description: [what you did]
  Tech stack: [tools and technologies]

**Skills:**
[List your main skill categories and tools]

**Talks or presentations:**
[List any YouTube links or conference talks, or say "none"]

**Mentorship:**
[Describe any mentorship work, or say "none"]

**Color theme:**
- Primary color: [e.g. indigo, teal, orange — or provide a hex code]

**Domain:**
- Website URL: [your domain or subdomain]

Once I provide these details, please:
1. Update index.html with my information
2. Update styles.css to use my chosen color as the primary theme color
3. Update the meta description and page title
4. Update terraform/terraform.tfvars with my domain name
5. Keep the bilingual (EN/ES) structure but update all content to reflect my details
```

---

## Tech stack

- HTML5, CSS3, Vanilla JavaScript
- Nginx + Docker
- AWS S3 + CloudFront + Route53 + ACM
- Terraform

## License

© 2026 Carolina Herrera Monteza. All rights reserved.

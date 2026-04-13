# Part 1 — Build Your Website Locally (40 min)

In this part you'll clone the repo, run the website on your machine, and use Kiro to replace all the content with your own details.

---

## Step 1 — Clone the repo (2 min)

```bash
git clone https://github.com/carotechie/web-portfolio.git
cd web-portfolio
```

Open the folder in Kiro IDE.

---

## Step 2 — Run it locally (5 min)

Make sure Docker Desktop is running, then:

```bash
./run-local.sh
```

Open http://localhost — you should see Carolina's website. This is your starting point.

---

## Step 3 — Personalize with Kiro (30 min)

Open Kiro chat and use the prompt below. Fill in your own details before sending it.

```
I want to customize this portfolio website with my own details.

Personal info:
- Name: [Your Full Name]
- Title: [Your Job Title, e.g. "Backend Engineer" or "Data Scientist"]
- Years of experience: [X]
- Bio: [2-3 sentences about yourself and what you do]
- LinkedIn: [your LinkedIn URL]
- GitHub: [your GitHub URL]
- Blog: [your blog URL, or say "none"]
- Instagram / X / YouTube: [your handles, or say "none" for any you don't use]

Experience (list each role):
- [Year range] | [Job Title] | [Company]
  Description: [what you did in 1-2 sentences]
  Tech stack: [comma-separated tools and technologies]

Skills (list your main areas and tools):
- [Category]: [tool1, tool2, tool3]
- [Category]: [tool1, tool2, tool3]

Talks or presentations:
[Paste YouTube links if you have any, or say "none"]

Mentorship:
[Describe any mentorship work you do, or say "none"]

Color theme:
- Primary color: [e.g. teal, orange, blue — or a hex code like #0ea5e9]

Domain:
- Website URL: [your domain or subdomain, e.g. tech.yourname.com]

Please:
1. Update index.html with all my information above
2. Update styles.css to use my chosen color as the primary theme
3. Update the page title and meta description
4. Update terraform/terraform.tfvars with my domain name
5. Keep the bilingual EN/ES structure but update all content to reflect my details
```

After Kiro applies the changes, refresh http://localhost to see your version.

---

## Step 4 — Fine-tune (3 min)

Not happy with something? Use these follow-up prompts in Kiro:

**Change a color:**
```
Change the primary color to #YOUR_HEX_CODE and update all references in styles.css
```

**Update a section:**
```
Update the mentorship section in index.html to say: [your text]
```

**Remove a section you don't need:**
```
Remove the Talks section from index.html and the navigation link for it
```

**Add a section:**
```
Add a Projects section after Experience with these projects: [list them]
```

---

## Checkpoint

Before moving to Part 2, make sure:

- [ ] Website runs at http://localhost
- [ ] Your name and title appear in the hero section
- [ ] Your experience and skills are correct
- [ ] Colors look the way you want
- [ ] No broken images or layout issues

---

Next: [Part 2 — Deploy to AWS](WORKSHOP_PART2_AWS.md)

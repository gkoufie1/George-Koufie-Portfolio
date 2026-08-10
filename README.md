# George Koufie — Portfolio

Personal portfolio website for **George Koufie**, Cloud Infrastructure Engineer. Built with plain HTML/CSS/JS and deployed to AWS Amplify Hosting via Git-based CI/CD (auto-builds on every push to `main`). Docker/nginx are included for local preview and mirror the production security headers.

**Live site:** [georgekoufie.online](https://georgekoufie.online)

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | HTML5, CSS3, Vanilla JavaScript |
| Web Server (local preview) | nginx 1.29 (Alpine) |
| Containerization (local preview) | Docker |
| CI/CD | AWS Amplify Hosting (Git-based) + GitHub Actions (PR validation) |
| Hosting | AWS Amplify Hosting |
| DNS | Custom domain — georgekoufie.online |
| Contact Form | Formspree |
| Fonts | Google Fonts (Space Mono, Bebas Neue, Inter) |

---

## Project Structure

```
├── index.html                    # Main single-page site
├── amplify.yml                   # Amplify Hosting build spec (static, no build step)
├── customHttp.yml                # Amplify Hosting security headers + cache-control
├── Dockerfile                    # nginx:alpine container — local preview only
├── nginx.conf                    # Local preview: caching, security headers, SPA fallback
├── robots.txt                    # Search engine directives
├── sitemap.xml                   # XML sitemap
├── assets/
│   ├── css/
│   │   ├── main.css              # Core styles and layout
│   │   └── animations.css        # Scroll fade-in animations
│   ├── js/
│   │   └── main.js               # Intersection observer + form handler
│   └── images/
│       ├── og-image.png          # Open Graph / Twitter share image
│       └── favicon/              # Favicon, apple-touch-icon, webmanifest
├── resume/
│   └── George-Koufie-Portfolio.pdf
└── .github/
    └── workflows/
        └── deploy.yml            # PR/push validation (docker build + nginx -t) — not deployment
```

---

## CI/CD Pipeline

Deployment and validation are split across two systems:

- **AWS Amplify Hosting** is connected directly to this GitHub repo. Every push to `main` triggers Amplify to pull the repo, run `amplify.yml` (no build step — it's static HTML/CSS/JS), apply the headers in `customHttp.yml`, and publish to the CDN. No GitHub secrets are needed for this — Amplify holds its own repo access token internally.
- **GitHub Actions** (`.github/workflows/deploy.yml`) runs on every push/PR as a sanity check: builds the local preview Docker image and validates the nginx config (`nginx -t`). It does not deploy anything.

```
Push to main
    │
    ├──▶ AWS Amplify Hosting (Git-integrated)
    │        │
    │        ▼
    │    Build per amplify.yml (static — no build step)
    │        │
    │        ▼
    │    Apply headers (customHttp.yml) → publish to CDN
    │        │
    │        ▼
    │    Live at georgekoufie.online
    │
    └──▶ GitHub Actions: docker build + nginx -t   (PR/local sanity check only)
```

No GitHub Actions secrets are required for deployment.

**One-time setup** (done once via the AWS Console, since connecting a GitHub repo requires an interactive OAuth authorization):

1. AWS Console → Amplify → **Create app** → Host a web app → GitHub → authorize AWS Amplify's GitHub App → select this repo and the `main` branch.
2. Amplify auto-detects `amplify.yml`; accept the default build settings and deploy.
3. App settings → **Custom headers** → point it at `customHttp.yml` (or paste its contents) so the security headers ship in production.
4. App settings → **Domain management** → add `georgekoufie.online`, then update your DNS with the CNAME/ALIAS records Amplify provides.
5. Every subsequent push to `main` deploys automatically — no further console steps needed.

---

## Local Development

**Prerequisites:** Docker installed

```bash
# Clone the repository
git clone https://github.com/gkoufie/george-koufie-portfolio.git
cd george-koufie-portfolio

# Build the Docker image
docker build -t george-koufie-portfolio .

# Run locally
docker run -d -p 8080:80 --name portfolio george-koufie-portfolio

# Open in browser
open http://localhost:8080
```

To stop:

```bash
docker rm -f portfolio
```

---

## Headers & Caching

The same policy is enforced in both environments, just via different mechanisms:

| | Local preview (Docker) | Production (Amplify) |
|---|---|---|
| Config file | `nginx.conf` | `customHttp.yml` |
| Static asset caching | 1 year, `immutable` | 1 year, `immutable` |
| SPA fallback | `try_files` → `index.html` | Amplify default |
| Security headers | `Strict-Transport-Security`, `X-Frame-Options`, `X-Content-Type-Options`, `X-XSS-Protection`, `Referrer-Policy`, `Content-Security-Policy` | same |

---

## Sections

| Section | Description |
|---|---|
| Hero | Name, title, stats (3+ years, 10 certs, 7 projects) |
| About | Terminal-style card with key/value layout |
| Skills | 6 categories matching the resume: Cloud Platforms (AWS), IaC, CI/CD & Containers, Networking & Security, Linux & Scripting, AI-Augmented Development |
| Projects | 7 real projects from the resume (Hybrid Cloud Network, Serverless Link Shortener, DevSecOps Pipeline, Security Baseline Audit Tool, AI-Augmented Cloud Development, Enterprise AWS Landing Zone, Event-Driven Security Guardrail) |
| Resume | Education timeline and certification chips + PDF download (work experience omitted from the page — visible in the downloadable PDF only) |
| Contact | Form (Formspree) + LinkedIn, GitHub, YouTube, email links |

---

## Deployment Architecture

```
GitHub (push to main)
        │
        ▼
AWS Amplify Hosting (Git-connected app)
        │
        ├── amplify.yml       → static build (no compile step)
        ├── customHttp.yml    → security headers + cache-control
        └── Managed CDN (CloudFront under the hood)
                │
                └── georgekoufie.online
```

Cost: AWS Amplify Hosting's free tier (1,000 build minutes/month, 15 GB served/month, 5 GB stored) comfortably covers a low-traffic personal portfolio — effectively $0/month.

---

## Certifications

- AWS Certified Solutions Architect – Associate
- AWS Certified Cloud Practitioner
- Microsoft Certified: Azure Administrator Associate (AZ-104)
- Microsoft Certified: Azure Fundamentals (AZ-900)
- CompTIA Cloud+
- CompTIA Security+
- CompTIA Network+
- CompTIA A+
- CompTIA Project+
- LPI Linux Essentials

---

## Contact

- **Email:** gkoufie224@gmail.com
- **LinkedIn:** [linkedin.com/in/george-koufie](https://www.linkedin.com/in/george-koufie/)
- **GitHub:** [github.com/gkoufie1](https://github.com/gkoufie1)
- **YouTube:** [youtube.com/@cloudcapecoast](https://youtube.com/@cloudcapecoast)

---

© 2026 George Koufie. All systems operational.

# George Koufie — Portfolio

Personal portfolio website for **George Koufie**, Cloud Engineer (AWS, Azure & Terraform). A single self-contained `index.html` — all styles are inline in its `<style>` block — deployed to AWS Amplify Hosting via Git-based CI/CD (auto-builds on every push to `main`). Docker/nginx are included for local preview and mirror the production security headers.

**Live site:** [georgekoufie.online](https://georgekoufie.online)

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Single-file HTML5 + inline CSS, no JavaScript, no build step |
| Fonts | System font stack (`system-ui`, `-apple-system`, `Segoe UI`) — no external font requests |
| Structured data | JSON-LD (`Person`) in `<head>`, for search engines |
| Web Server (local preview) | nginx 1.29 (Alpine) |
| Containerization (local preview) | Docker |
| CI/CD | AWS Amplify Hosting (Git-based) + GitHub Actions (PR validation only) |
| Hosting | AWS Amplify Hosting |
| DNS | Custom domain — georgekoufie.online |
| Credential verification | AWS/Microsoft official verification pages; personal Credly badge links for CompTIA certs; a personal LPI verification link |

`assets/css/main.css`, `assets/css/animations.css`, and `assets/js/main.js` are leftovers from an earlier design and are **not loaded by the current `index.html`**. They're harmless but unused — safe to delete in a future cleanup.

---

## Project Structure

```
├── index.html                    # The entire site: markup + inline <style>, one page
├── amplify.yml                   # Amplify Hosting build spec (static, no build step)
├── customHttp.yml                # Amplify Hosting security headers + cache-control
├── Dockerfile                    # nginx:alpine container — local preview only
├── nginx.conf                    # Local preview: caching, security headers, SPA fallback
├── robots.txt                    # Search engine directives
├── sitemap.xml                   # XML sitemap (with <lastmod>)
├── assets/
│   ├── css/                      # Unused by index.html (see Tech Stack note above)
│   ├── js/                       # Unused by index.html (see Tech Stack note above)
│   └── images/
│       ├── headshot.jpg          # Hero portrait
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

Deployment and validation are split across two systems, and `main` is branch-protected: every change lands through a pull request with a passing `Validate` check, with no exceptions for the repo owner.

- **AWS Amplify Hosting** is connected directly to this GitHub repo. Every push to `main` triggers Amplify to pull the repo, run `amplify.yml` (no build step — it's a static file), apply the headers in `customHttp.yml`, and publish to the CDN. No GitHub secrets are needed for this — Amplify holds its own repo access token internally.
- **GitHub Actions** (`.github/workflows/deploy.yml`) runs on every push/PR as a sanity check: builds the local preview Docker image and validates the nginx config (`nginx -t`). It does not deploy anything.

```
Open a PR into main
    │
    ├──▶ GitHub Actions: docker build + nginx -t   (required check)
    │
    ▼
Merge (branch protection: PR + passing check required, no bypass)
    │
    ▼
AWS Amplify Hosting (Git-integrated)
    │
    ▼
Build per amplify.yml (static — no build step)
    │
    ▼
Apply headers (customHttp.yml) → publish to CDN
    │
    ▼
Live at georgekoufie.online
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
git clone https://github.com/gkoufie1/George-Koufie-Portfolio.git
cd George-Koufie-Portfolio

# Build the Docker image
docker build -t george-koufie-portfolio .

# Run locally
docker run -d -p 8081:8080 --name portfolio george-koufie-portfolio

# Open in browser
open http://localhost:8081
```

To stop:

```bash
docker rm -f portfolio
```

(Or skip Docker entirely — `index.html` has no build step, so opening it directly in a browser, or serving the folder with any static file server, works too.)

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
| Hero | Headline, two-sentence intro, portrait, and quick stats |
| Projects | 3 featured projects (AWS Reliability Lab, Azure DR drill, EKS GitOps DR), each with a measured result and a repo link; the remaining 6 projects sit behind a "More projects" `<details>` toggle |
| Experience | Current role: Solutions Architect (Contract) at EpixDevo |
| Skills | Hands-on focus list, plus a compact Credentials list — each certification with a personal or official verification link (no large certificate images, no Credly embed script) |
| Writing | Published LinkedIn articles and a Medium post |
| Services | Contract engagements available outside the EpixDevo client base |
| Contact | Email, LinkedIn, GitHub, résumé download |

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
- Microsoft Certified: Azure Administrator Associate (AZ-104)
- CompTIA Security+
- CompTIA Network+
- CompTIA Cloud+
- CompTIA Project+
- CompTIA A+
- LPI Linux Essentials
- B.S. Cloud Computing, Western Governors University

---

## Contact

- **Email:** gkoufie224@gmail.com
- **LinkedIn:** [linkedin.com/in/george-koufie](https://www.linkedin.com/in/george-koufie/)
- **GitHub:** [github.com/gkoufie1](https://github.com/gkoufie1)

---

© 2026 George Koufie. All systems operational.

# George Koufie — Portfolio

Personal portfolio website for **George Koufie**, Cloud & DevOps Engineer. Built with plain HTML/CSS/JS, containerized with Docker, and deployed to AWS EC2 via a fully automated GitHub Actions CI/CD pipeline.

**Live site:** [georgekoufie.dev](https://georgekoufie.dev)

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | HTML5, CSS3, Vanilla JavaScript |
| Web Server | nginx 1.27 (Alpine) |
| Containerization | Docker |
| CI/CD | GitHub Actions |
| Hosting | AWS EC2 |
| DNS | Custom domain — georgekoufie.dev |
| Contact Form | Formspree |
| Fonts | Google Fonts (Space Mono, Bebas Neue, Inter) |

---

## Project Structure

```
├── index.html                    # Main single-page site
├── Dockerfile                    # nginx:alpine container definition
├── nginx.conf                    # Static caching, security headers, SPA fallback
├── robots.txt                    # Search engine directives
├── assets/
│   ├── css/
│   │   ├── main.css              # Core styles and layout
│   │   └── animations.css        # Scroll fade-in animations
│   ├── js/
│   │   └── main.js               # Intersection observer + form handler
│   └── images/
│       └── favicon/              # Favicon, apple-touch-icon, webmanifest
├── resume/
│   └── George-Koufie-Portfolio.pdf
└── .github/
    └── workflows/
        └── deploy.yml            # CI/CD pipeline
```

---

## CI/CD Pipeline

Every push to `main` triggers a fully automated deployment:

```
Push to main
    │
    ▼
Build Docker image (tagged with run number + latest)
    │
    ▼
Verify EC2 port 22 reachability
    │
    ▼
SCP compressed image to EC2
    │
    ▼
SSH → docker load → remove old container → run new container
    │
    ▼
Health check (10 retries × 3s) → HTTP 200 required
    │
    ▼
Cleanup sensitive files (runs on success AND failure)
```

**Secrets used:**

| Secret | Description |
|---|---|
| `PORTFOLIO_SSH_KEY` | EC2 SSH private key (PEM format) |
| `PORTFOLIO_SERVER_IP` | EC2 public IP address |

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

## nginx Configuration

The nginx server is configured with:

- **Static asset caching** — CSS, JS, images, fonts cached for 1 year with `immutable` directive
- **SPA fallback** — all routes fall back to `index.html`
- **Security headers:**
  - `X-Frame-Options: SAMEORIGIN`
  - `X-Content-Type-Options: nosniff`
  - `X-XSS-Protection: 1; mode=block`
  - `Referrer-Policy: strict-origin-when-cross-origin`

---

## Sections

| Section | Description |
|---|---|
| Hero | Name, title, stats (3+ years, 6 certs, 2 cloud platforms) |
| About | Terminal-style card with key/value layout |
| Skills | 6 categories: Cloud, IaC, Containers, CI/CD, Monitoring, Security |
| Projects | 4 featured projects (EKS, AKS, Lambda, Terraform) |
| Resume | Career timeline + PDF download |
| Contact | Form (Formspree) + LinkedIn, YouTube, email links |

---

## Deployment Architecture

```
GitHub (push to main)
        │
        ▼
GitHub Actions Runner (ubuntu-latest)
        │
        ├── docker build
        ├── docker save | gzip
        └── SCP + SSH
                │
                ▼
        AWS EC2 Instance
                │
                └── Docker Container (nginx:alpine)
                        │
                        └── Port 80 → georgekoufie.dev
```

---

## Certifications

- AWS Certified Solutions Architect – Associate
- Microsoft Azure Administrator (AZ-104)
- Certified Kubernetes Administrator (CKA)
- CompTIA Security+
- CompTIA Network+
- AWS Cloud Practitioner

---

## Contact

- **Email:** gkoufie224@gmail.com
- **LinkedIn:** [linkedin.com/in/george-koufie](https://www.linkedin.com/in/george-koufie/)
- **YouTube:** [youtube.com/@cloudcapecoast](https://youtube.com/@cloudcapecoast)

---

© 2026 George Koufie. All systems operational.

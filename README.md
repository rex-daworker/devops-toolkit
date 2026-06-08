# 🛠️ DevOps Automation Toolkit

> A hands-on collection of 18 production-style automation scripts spanning Linux, AWS, Terraform, Docker, CI/CD, and monitoring — built as a structured, end-to-end learning project.

🌐 **Live Portfolio Site:** http://rex-devops-toolkit-site.s3-website.eu-north-1.amazonaws.com

---

## 🧭 Guiding Principle

> **Automation should be powerful, but never destructive by accident.**

Every script in this toolkit is built with safety in mind — confirmation prompts before deletions, protected resources that can never be touched, and clear logging of every action taken.

---

## 🚀 What This Toolkit Does

This toolkit automates the everyday responsibilities of a DevOps engineer — keeping systems healthy, infrastructure consistent, backups current, and the team informed when something goes wrong. Every script logs its activity, most run automatically on a schedule, and critical events trigger real-time Slack alerts.

---

## 📂 Scripts by Category

### 🖥️ System & Maintenance
| Script | Purpose |
|--------|---------|
| `auto_update.sh` | Automated system package updates |
| `daily_backup.sh` | Scheduled backups of key directories |
| `log_rotation.sh` | Rotates and compresses old logs |
| `docker_prune.sh` | Cleans up unused Docker resources |

### ☁️ AWS & Cloud
| Script | Purpose |
|--------|---------|
| `s3_sync.sh` | Syncs local backups to AWS S3 |
| `ec2_health.sh` | Checks EC2 instance health |
| `cost_report.sh` | Monthly AWS cost reporting via Cost Explorer |
| `deploy_site.sh` | Deploys static site to S3 |

### 🏗️ Infrastructure as Code
| Script | Purpose |
|--------|---------|
| `drift_detect.sh` | Detects Terraform infrastructure drift |

### 🔒 Security & Data
| Script | Purpose |
|--------|---------|
| `vuln_scan.sh` | Scans system for vulnerabilities |
| `db_dump.sh` | Automated PostgreSQL database backups |

### 🐳 Containers & Monitoring
| Script | Purpose |
|--------|---------|
| `docker_monitor.sh` | Monitors container health + resource usage |
| `dashboard.sh` | Live system health dashboard |

### 🔔 Alerting & Workflow
| Script | Purpose |
|--------|---------|
| `alert.sh` | Reusable Slack + email alert function |
| `send_email.py` | Python email sender (Outlook SMTP) |
| `repo_sync.sh` | Auto-syncs local repos with GitHub |
| `til.sh` | "Today I Learned" logger |

### 🌿 Git & Safety
| Script | Purpose |
|--------|---------|
| `branch_cleanup.sh` | Safely removes merged branches (with confirmation + protected branches) |

### 🏆 Orchestration
| Script | Purpose |
|--------|---------|
| `toolkit.sh` | Master script — runs checks & generates a full status report |

---

## ⚙️ Tech Stack

- **Languages:** Bash, Python
- **Cloud:** AWS (EC2, S3, IAM, Cost Explorer)
- **IaC:** Terraform
- **Containers:** Docker, Docker Compose
- **CI/CD:** GitHub Actions
- **Monitoring & Alerts:** Slack Webhooks, custom dashboards
- **Scheduling:** cron

---

## 🔁 CI/CD Pipeline

Every push to this repository triggers an automated GitHub Actions pipeline that lints all Python code with flake8, ensuring code quality before changes are accepted.

---

## 🐳 Featured Project: Containerized DevOps Dashboard

A full-stack monitoring dashboard built and containerized as part of this toolkit:

- **Frontend:** React + TypeScript (served via nginx)
- **Backend:** Python FastAPI serving live system metrics
- **Orchestration:** Docker Compose running both services
- **Monitoring:** Tracked by `docker_monitor.sh` with automated alerts

---

## 🎓 What I Learned

This project took me from individual scripts to a cohesive automation system. Along the way I gained hands-on experience with:

- Writing safe, idempotent automation with proper logging and error handling
- Provisioning and managing real AWS infrastructure
- Detecting infrastructure drift with Terraform
- Building and orchestrating multi-container applications with Docker
- Setting up CI/CD pipelines that enforce code quality automatically
- Implementing real-time monitoring and alerting like a production system
- Managing secrets securely and keeping them out of version control
- Applying the principle that automation must be powerful but never destructive by accident

---

## 👤 Author

**Rex Oghenerobo** — Aspiring DevOps Engineer

📂 GitHub: [github.com/rex-daworker](https://github.com/rex-daworker)

# GitLab Kubernetes Deployment

**Repository:** [github.com/eric-holtzclaw/gitlab](https://github.com/eric-holtzclaw/gitlab)  
**GitLab:** http://gitlab.local/infrastructure/gitlab (or http://localhost:8080/infrastructure/gitlab via port-forward)  
**Purpose:** Self-hosted GitLab CE for CI/CD, source code management, and container registry  
**Cluster:** eric@10.0.0.10 (Ubuntu 24.04.3 LTS, Kubernetes v1.32.8)

**Change Tracking:** See [CHANGELOG.md](CHANGELOG.md) for all changes and documentation updates.

**Production-Ready Setup:** ✅ **COMPLETE** - See [PRODUCTION_READY_SETUP.md](PRODUCTION_READY_SETUP.md) for complete production-ready access configuration.

---

## 🎯 Overview

This repository contains Kubernetes manifests and deployment scripts for GitLab CE, configured for self-hosted CI/CD pipelines, source code repositories, and container image registry.

**CFORD Compliant:** ✅ All scripts follow CFORD principles (single source of truth, no duplicates)

---

## 📋 Scripts and Their Purposes

### Deployment Scripts

#### `scripts/deploy-gitlab.sh`
**Purpose:** Automated deployment script for GitLab
- Applies all Kubernetes manifests in correct order
- Verifies deployment status
- Checks pod health
- Provides access information

**Usage:**
```bash
cd /Users/ericholtzclaw/Scripts/browser/GitLab
./scripts/deploy-gitlab.sh
```

#### `scripts/start-port-forward.sh`
**Purpose:** Start port-forward for GitLab access
- Port-forwards HTTP (8080) and SSH (2222)
- Runs in background
- Provides access URLs

**Usage:**
```bash
./scripts/start-port-forward.sh
```

### Migration Scripts

#### `scripts/migrate-to-gitlab.sh`
**Purpose:** Migrate repositories from GitHub to GitLab
- Creates GitLab projects
- Imports repositories
- Configures mirroring (optional)

#### `scripts/batch-import.sh`
**Purpose:** Batch import multiple repositories from GitHub
- Imports all configured repositories
- Creates projects in appropriate groups
- Handles authentication via personal access token

#### `scripts/run-import.sh`
**Purpose:** Simple repository import with logging
- Imports single or multiple repositories
- Logs all operations
- Provides status feedback

### Configuration Scripts

#### `scripts/setup-ssh-access.sh`
**Purpose:** Configure SSH access to GitLab
- Adds SSH key to GitLab
- Configures SSH port-forward
- Tests SSH connection

#### `scripts/setup-gitlab-ci-cd-variables.sh`
**Purpose:** Configure CI/CD variables for projects
- Sets up Kubernetes credentials
- Configures registry access
- Sets deployment variables

#### `scripts/setup-github-mirroring.sh`
**Purpose:** Configure GitHub mirroring for repositories
- Sets up push mirroring (GitLab → GitHub)
- Configures webhook triggers
- Handles authentication

#### `scripts/configure-ci-cd-settings.sh`
**Purpose:** Configure global CI/CD settings
- Artifacts expiration
- Pipeline limits
- Forward deployment settings

### Automation Scripts

#### `scripts/enable-diagrams-net.sh`
**Purpose:** Enable diagrams.net integration in GitLab
- Configures via Admin API
- Enables `.drawio` file support

#### `scripts/enable-metrics-profiling.sh`
**Purpose:** Enable Prometheus metrics and performance profiling
- Enables metrics endpoint
- Configures performance bar
- Sets up monitoring

#### `scripts/complete-gitlab-setup.sh`
**Purpose:** Complete GitLab setup automation
- Runs all configuration scripts
- Sets up all features
- Configures integrations

### Monitoring Scripts

#### `scripts/check-gitlab-health.sh`
**Purpose:** Check GitLab health and status
- Verifies pod status
- Checks HTTP access
- Tests API endpoints
- Reports issues

#### `scripts/check-gitlab-status.sh`
**Purpose:** Quick status check
- Shows pod status
- Shows service status
- Shows recent logs

### Backup Scripts

#### `scripts/backup-gitlab.sh`
**Purpose:** Backup GitLab data and configuration
- Backs up persistent volume
- Exports configuration
- Creates backup archive

### Utility Scripts

#### `scripts/validate-secrets.sh`
**Purpose:** Validate Kubernetes secrets
- Checks secret existence
- Verifies secret format
- Tests secret access

#### `scripts/vault-to-k8s-secret.sh`
**Purpose:** Convert token vault to Kubernetes secret
- Reads token_vault.json
- Creates Kubernetes secret
- Applies to cluster

---

## 🌐 Service URLs and Access

### Prerequisites

**Add to `/etc/hosts` (Required):**

This is required because GitLab is configured with `external_url 'http://gitlab.local'` in `k8s/configmap.yaml`.

**macOS/Linux:**
```bash
sudo bash -c 'echo "127.0.0.1 gitlab.local" >> /etc/hosts'
```

**Windows (PowerShell as Administrator):**
```powershell
Add-Content -Path "$env:windir\System32\drivers\etc\hosts" -Value "`n127.0.0.1 gitlab.local" -Force
```

**Note:** This change is **persistent** - it survives reboots.

**📖 For detailed setup instructions, see [SETUP_GUIDE.md](SETUP_GUIDE.md)**

### Browser Access (via Port-Forward)

After starting port-forward:
```bash
kubectl port-forward -n gitlab service/gitlab-service 8080:80
```

- **Web UI:** http://localhost:8080
- **API:** http://localhost:8080/api/v4

### Git Remote URLs

**Best Practice: Use SSH (Recommended)**

- **SSH:** `ssh://git@localhost:2222/group/repo.git`
- No credentials needed, more secure, works reliably

**Alternative: HTTP with localhost:8080**

- **HTTP:** `http://localhost:8080/group/repo.git`
- Requires credentials (root password or Personal Access Token)

**Note:** Use `localhost` (not `gitlab.local`) because port-forward is on localhost:8080. GitLab is configured with `external_url 'http://gitlab.local'` but accessible via port-forward on localhost:8080.

**Example (SSH - Recommended):**
```bash
git remote add origin ssh://git@localhost:2222/open-source-development/google-workspace-forensics-investigator.git
git branch -M main
git push -uf origin main
```

**Example (HTTP):**
```bash
# With Personal Access Token (best for automation)
git remote add origin http://oauth2:${GITLAB_TOKEN}@localhost:8080/open-source-development/google-workspace-forensics-investigator.git

# With root password (URL encode special characters)
ENCODED_PASS=$(python3 -c "import urllib.parse; print(urllib.parse.quote('ChangeMe123!@#SecurePassword'))")
git remote add origin http://root:${ENCODED_PASS}@localhost:8080/open-source-development/google-workspace-forensics-investigator.git
```

**📖 See [BEST_PRACTICES_GITLAB_ACCESS.md](BEST_PRACTICES_GITLAB_ACCESS.md) for complete best practices guide.**

---

## 🔧 Troubleshooting

### Permission Issues

If GitLab pod is crashing with permission errors, see:
- [GITLAB_PERMISSION_FIX_COMPLETE.md](GITLAB_PERMISSION_FIX_COMPLETE.md) - Complete fix documentation
- [WHY_PERMISSIONS_ISSUES.md](WHY_PERMISSIONS_ISSUES.md) - Root cause analysis

**Quick Reference - GitLab Service UIDs:**
- PostgreSQL: `996:996` (gitlab-psql)
- Redis: `997:997` (gitlab-redis)
- GitLab Rails: `998:998` (git)
- Nginx: `999:999` (gitlab-www)

### Monitoring

Automated monitoring runs every 2 minutes via cron:
- Script: `scripts/monitor-gitlab.sh`
- Logs: `/tmp/gitlab-monitor.log`
- Cron logs: `/tmp/gitlab-monitor-cron.log`

**View status:**
```bash
tail -f /tmp/gitlab-monitor.log
```

---

## 📝 Change Tracking

All changes are documented in:
- [CHANGELOG.md](CHANGELOG.md) - Detailed change history
- [GITLAB_PERMISSION_FIX_COMPLETE.md](GITLAB_PERMISSION_FIX_COMPLETE.md) - Permission fixes
- [WHAT_WENT_WRONG.md](WHAT_WENT_WRONG.md) - Configuration issues

---

## 🚀 Production-Ready Access

**Status:** ✅ **PRODUCTION READY - ALL COMPLETE**

**Complete Setup:** See [PRODUCTION_READY_SETUP.md](PRODUCTION_READY_SETUP.md)

### Quick Summary:

1. **✅ Automatic Port Forwarding on Restart**
   - LaunchAgent: `~/Library/LaunchAgents/com.gitlab.portforward.plist` (loaded and active)
   - Management: `scripts/manage-port-forward.sh` (start/stop/restart/status/test)
   - Auto-starts on Mac login/restart

2. **✅ All Access Methods Configured**
   - SSH Keys: Configured (primary, deploy, HA keys)
   - Root Password: Working (URL-encoded, HTTP access)
   - Token Access: Personal Access Token configured
   - **HTTP is recommended** (SSH port 2222 has known issues)

3. **✅ End-to-End Testing**
   - Test script: `scripts/test-end-to-end.sh`
   - All tests passing (port forwarding, HTTP access, git operations)

**Repository:** http://localhost:8080/infrastructure/gitlab

### Kubernetes Service
- **Namespace:** `gitlab`
- **Service:** `gitlab-service`
- **Ports:** 80 (HTTP), 443 (HTTPS), 2222 (SSH)

### Default Credentials
- **Username:** `root`
- **Password:** Check `k8s/secret.yaml` or `token_vault.json`
- ⚠️ **IMPORTANT:** Change root password after first login!

### Port-Forward for SSH

For SSH access, also start SSH port-forward:
```bash
kubectl port-forward -n gitlab service/gitlab-service 2222:2222
```

---

## 📁 Repository Structure

```
GitLab/
├── k8s/                          # Kubernetes manifests
│   ├── namespace.yaml            # Namespace definition
│   ├── pv-local.yaml             # PersistentVolume (50Gi)
│   ├── pvc.yaml                 # PersistentVolumeClaim
│   ├── configmap.yaml            # GitLab configuration
│   ├── secret.yaml               # Secrets (DO NOT COMMIT)
│   ├── deployment.yaml           # GitLab deployment
│   ├── service.yaml              # Service definition
│   └── README.md                 # K8s manifests documentation
├── scripts/                       # Deployment and management scripts
│   ├── deploy-gitlab.sh          # Main deployment script
│   ├── start-port-forward.sh     # Port-forward helper
│   ├── migrate-to-gitlab.sh      # Migration helper
│   ├── batch-import.sh           # Batch import script
│   ├── run-import.sh             # Simple import script
│   ├── setup-ssh-access.sh       # SSH configuration
│   ├── setup-gitlab-ci-cd-variables.sh  # CI/CD setup
│   ├── setup-github-mirroring.sh  # GitHub mirroring
│   ├── configure-ci-cd-settings.sh  # Global CI/CD config
│   ├── enable-diagrams-net.sh    # Diagrams.net integration
│   ├── enable-metrics-profiling.sh  # Metrics setup
│   ├── complete-gitlab-setup.sh  # Complete automation
│   ├── check-gitlab-health.sh    # Health monitoring
│   ├── check-gitlab-status.sh    # Status check
│   ├── backup-gitlab.sh          # Backup script
│   ├── validate-secrets.sh        # Secret validation
│   └── vault-to-k8s-secret.sh    # Secret conversion
├── token_vault.json              # Secrets vault (DO NOT COMMIT)
├── token_vault.json.example       # Example vault file
├── README.md                      # This file
└── [Documentation files]          # Various .md files
```

---

## 🚀 Quick Start

### Deploy GitLab

```bash
cd /Users/ericholtzclaw/Scripts/browser/GitLab
./scripts/deploy-gitlab.sh
```

### Start Port-Forward

```bash
./scripts/start-port-forward.sh
```

### Access GitLab

1. Open browser: http://localhost:8080
2. Login with root credentials
3. Change default password immediately

---

## 📊 Resource Requirements

- **Memory:** 4Gi request, 8Gi limit
- **CPU:** 2000m request, 4000m limit
- **Storage:** 50Gi minimum (expandable)

**Server Capacity:** 24 cores, 131GB RAM ✅

---

## ⏱️ Startup Time

**GitLab takes 5-10 minutes to fully start.**

The first startup is slower as GitLab:
- Initializes PostgreSQL database
- Configures Redis
- Sets up repositories structure
- Runs initial migrations

Check status:
```bash
kubectl get pods -n gitlab
kubectl logs -n gitlab deployment/gitlab -f
```

---

## 🔧 Configuration

### GitLab Configuration

Edit `k8s/configmap.yaml` to customize:
- External URL
- Performance settings
- Email configuration
- SSL/TLS settings

### Resource Limits

Edit `k8s/deployment.yaml` to adjust:
- Memory requests/limits
- CPU requests/limits
- Storage size

### Secrets

Edit `k8s/secret.yaml` or use `token_vault.json`:
- Root password
- Root email

---

## 🔍 Verification & Troubleshooting

### Check Deployment Status

```bash
# All resources
kubectl get all -n gitlab

# Pods
kubectl get pods -n gitlab

# Storage
kubectl get pvc -n gitlab
kubectl get pv

# Service
kubectl get svc -n gitlab
```

### View Logs

```bash
# GitLab logs
kubectl logs -n gitlab deployment/gitlab -f

# Previous logs (if pod restarted)
kubectl logs -n gitlab deployment/gitlab --previous
```

### Common Issues

1. **Pod not starting:** Check logs for errors
2. **Storage issues:** Verify PV/PVC are bound correctly
3. **Slow startup:** Normal for GitLab (5-10 minutes)
4. **Can't access:** Check port-forward is running

---

## 📚 Related Documentation

- **🆕 New User Setup:** [SETUP_GUIDE.md](SETUP_GUIDE.md) - Complete setup for Mac, Linux, and Windows
- **Change Tracking:** [CHANGELOG.md](CHANGELOG.md) - All changes tracked here
- **CFORD Compliance:** [CFORD_COMPLIANCE.md](CFORD_COMPLIANCE.md) - Change tracking process
- **SSH Access:** [SSH_ACCESS_GUIDE.md](SSH_ACCESS_GUIDE.md) - SSH setup guide
- **Secret Management:** [SECRET_MANAGEMENT_STRATEGY.md](SECRET_MANAGEMENT_STRATEGY.md) - Secret management best practices
- **Core K8s DevOps:** `/Users/ericholtzclaw/Scripts/core/k8s-devops/`
- **N8N Deployment:** Similar deployment pattern
- **GitLab Docs:** https://docs.gitlab.com/

## 🔄 Change Tracking

**All changes are tracked in [CHANGELOG.md](CHANGELOG.md).**

When making changes:
1. Make the change
2. Update `CHANGELOG.md` with change details
3. Update relevant documentation
4. Commit together (change + CHANGELOG + docs)

This ensures documentation stays in sync with actual implementation. See [CFORD_COMPLIANCE.md](CFORD_COMPLIANCE.md) for the complete change tracking process.

---

## 🔗 Related Repositories

- **core:** Kubernetes DevOps tools and deployment scripts
- **supabase:** Backend database deployment
- **nginx:** Reverse proxy configuration
- **N8N:** Workflow automation (similar deployment pattern)

---

**Last Updated:** November 2025  
**Status:** ✅ Production Ready  
**CFORD Compliant:** ✅ Yes

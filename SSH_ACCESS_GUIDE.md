# GitLab SSH Access Setup Guide

**Date:** November 4, 2025  
**Status:** ✅ Script Ready - SSH Access Configured

---

## 🎯 Quick Setup

Run the automated setup script:

```bash
cd /Users/eric/Documents/Scripts/infrastructure/gitlab
./scripts/setup-ssh-access.sh
```

This script will:
1. ✅ Find your SSH public key
2. ✅ Add it to GitLab via API
3. ✅ Test the SSH connection
4. ✅ Show you how to use it

---

## 📋 Prerequisites

### 1. SSH Key (if you don't have one)

```bash
# Generate a new SSH key (if needed)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Or use existing RSA key
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

### 2. Port-Forward Running

The script will auto-start port-forward, but you can also start it manually:

```bash
# HTTP/HTTPS
kubectl port-forward -n gitlab service/gitlab-service 8080:80

# SSH (in another terminal)
kubectl port-forward -n gitlab service/gitlab-service 2222:2222
```

---

## 🔧 How It Works

### GitLab SSH Configuration

GitLab is already configured for SSH:
- **Port:** 2222 (configured in `k8s/configmap.yaml`)
- **Service:** Exposes port 2222 (in `k8s/service.yaml`)
- **Protocol:** Standard Git SSH protocol

### SSH Key Management

The script adds your SSH public key to GitLab using the API:
- **Endpoint:** `POST /api/v4/user/keys`
- **Authentication:** Personal Access Token
- **Key Title:** `hostname-YYYYMMDD` (e.g., `macbook-20251104`)

---

## 🚀 Using GitLab SSH

### Prerequisites

**Add to `/etc/hosts` (Required):**
```
127.0.0.1 gitlab.local
```

This is required because GitLab is configured with `external_url 'http://gitlab.local'` in `k8s/configmap.yaml`.

### Clone a Repository

```bash
git clone ssh://git@gitlab.local:2222/infrastructure/core.git
```

### Add GitLab Remote

```bash
cd /path/to/your/repo
git remote add gitlab ssh://git@gitlab.local:2222/infrastructure/core.git
```

### Push to GitLab

```bash
git push gitlab main
```

### Pull from GitLab

```bash
git pull gitlab main
```

---

## 🔍 Verify SSH Access

### Test Connection

```bash
ssh -T -p 2222 git@localhost
```

**Expected output:**
```
Welcome to GitLab, @root!
```

Or if it fails with exit code:
```
Welcome to GitLab, @root!
Connection to localhost closed.
```

(This is normal - GitLab may return non-zero exit code even on success)

---

## 📝 SSH URL Format

GitLab SSH URLs follow this format:
```
ssh://git@gitlab.local:2222/GROUP/PROJECT.git
```

**Note:** GitLab is configured with `external_url 'http://gitlab.local'`, so use `gitlab.local` (not `localhost`).

For your setup:
```
ssh://git@gitlab.local:2222/infrastructure/core.git
ssh://git@gitlab.local:2222/microsoft-development/o365-forensics-investigator.git
ssh://git@gitlab.local:2222/automation/n8n.git
ssh://git@gitlab.local:2222/development/google-workspace-forensics-investigator.git
```

**HTTP URLs (alternative):**
```
http://gitlab.local/group/repo.git
```

---

## 🛠️ Troubleshooting

### Issue: "Could not resolve host: gitlab.local"

**Solution:** Add gitlab.local to `/etc/hosts`:
```bash
echo "127.0.0.1 gitlab.local" | sudo tee -a /etc/hosts
```

### Issue: "Connection refused"

**Solution:** Start SSH port-forward:
```bash
kubectl port-forward -n gitlab service/gitlab-service 2222:2222
```

### Issue: "Permission denied (publickey)"

**Solution:** Run the setup script to add your SSH key:
```bash
./scripts/setup-ssh-access.sh
```

Or add SSH key manually via GitLab UI:
1. Go to: http://localhost:8080/-/profile/keys
2. Click "Add new key"
3. Paste your public key
4. Click "Add key"

### Issue: "Host key verification failed"

**Solution:** Add gitlab.local to known_hosts:
```bash
ssh-keyscan -p 2222 gitlab.local >> ~/.ssh/known_hosts
```

Or disable strict checking:
```bash
ssh -o StrictHostKeyChecking=no -p 2222 git@gitlab.local
```

---

## 🔐 Security Notes

1. **SSH Key Management:**
   - Your SSH key is stored in GitLab user profile
   - You can view/manage keys at: http://localhost:8080/-/profile/keys

2. **Port-Forward Security:**
   - Port-forward only works locally (localhost)
   - SSH is not exposed externally (ClusterIP service)
   - For external access, consider LoadBalancer or Ingress

3. **Multiple SSH Keys:**
   - You can add multiple SSH keys
   - Each key gets a unique title
   - All keys work for the same user

---

## 📊 Comparison: GitHub vs GitLab SSH

| Feature | GitHub | GitLab |
|---------|--------|--------|
| SSH Port | 22 | 2222 (configurable) |
| URL Format | `git@github.com:user/repo.git` | `ssh://git@gitlab.local:2222/group/repo.git` |
| Key Management | GitHub UI | GitLab UI or API |
| Port-Forward | Not needed | Required (2222 for SSH, 8080 for HTTP) |
| /etc/hosts | Not needed | Required (127.0.0.1 gitlab.local) |

---

## 🎯 Next Steps

1. ✅ **Run setup script** - `./scripts/setup-ssh-access.sh`
2. ✅ **Test SSH connection** - `ssh -T -p 2222 git@localhost`
3. ✅ **Clone a repo** - `git clone ssh://git@localhost:2222/infrastructure/core.git`
4. ⏳ **Set up mirroring** (if needed) - Use SSH for push mirroring

---

**Last Updated:** November 4, 2025




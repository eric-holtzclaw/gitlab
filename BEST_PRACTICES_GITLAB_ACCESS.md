# GitLab Access Best Practices

**Date:** November 5, 2025  
**Context:** GitLab deployed in Kubernetes with port-forward access

---

## 🎯 Best Practice: Current Setup (Development/Local)

### ✅ Recommended Approach

**For Kubernetes Deployment with Port-Forward:**

1. **Browser Access:**
   - Use: `http://localhost:8080` (via port-forward)
   - Port-forward: `kubectl port-forward -n gitlab service/gitlab-service 8080:80`

2. **Git Operations (SSH) - ⭐ RECOMMENDED:**
   - Use: `ssh://git@localhost:2222/group/repo.git`
   - Port-forward: `kubectl port-forward -n gitlab service/gitlab-service 2222:2222`
   - **Why:** No credentials needed, more secure, works reliably

3. **Git Operations (HTTP) - Alternative:**
   - Use: `http://localhost:8080/group/repo.git`
   - Requires credentials (root password or Personal Access Token)
   - **Why:** Works but requires password management

---

## 🔧 Configuration Alignment Issue

### Current Mismatch

**GitLab Config:** `external_url 'http://gitlab.local'` (port 80)  
**Actual Access:** `localhost:8080` (port-forward)

**Problem:** GitLab generates URLs using `gitlab.local`, but we access via `localhost:8080`.

### Best Practice Solutions

#### Option 1: Use localhost for Everything (Current Practice) ✅

**For Development/Testing:**
- Browser: `http://localhost:8080`
- Git SSH: `ssh://git@localhost:2222/group/repo.git`
- Git HTTP: `http://localhost:8080/group/repo.git`

**Pros:**
- ✅ Works immediately with port-forward
- ✅ No DNS configuration needed
- ✅ Simple for local development

**Cons:**
- ⚠️ URLs don't match `external_url` config
- ⚠️ GitLab UI shows `gitlab.local` URLs (may not work)

#### Option 2: Use gitlab.local with Port Specification

**Configure:**
- Add to `/etc/hosts`: `127.0.0.1 gitlab.local`
- Use: `http://gitlab.local:8080` (explicit port)
- Git SSH: `ssh://git@gitlab.local:2222/group/repo.git`

**Pros:**
- ✅ Matches `external_url` domain
- ✅ More consistent with GitLab config

**Cons:**
- ⚠️ GitLab may reject requests on port 8080 (expects port 80)
- ⚠️ Requires `/etc/hosts` entry

#### Option 3: Change external_url to Match Port-Forward (Recommended)

**Best Practice for Port-Forward Setup:**

Update `k8s/configmap.yaml`:
```yaml
external_url 'http://localhost:8080'
```

**Pros:**
- ✅ GitLab URLs match actual access method
- ✅ Clone buttons show correct URLs
- ✅ No confusion

**Cons:**
- ⚠️ Tied to localhost (not suitable for production)
- ⚠️ Won't work if accessed from different machine

#### Option 4: Use LoadBalancer/Ingress (Production)

**For Production:**
- Change service to `LoadBalancer` or use `Ingress`
- Configure proper DNS: `gitlab.yourdomain.com`
- Update `external_url` to match: `https://gitlab.yourdomain.com`

**Pros:**
- ✅ Proper production setup
- ✅ Accessible from anywhere
- ✅ No port-forward needed
- ✅ Can use SSL/TLS

**Cons:**
- ⚠️ Requires LoadBalancer or Ingress setup
- ⚠️ Requires DNS configuration
- ⚠️ More complex

---

## 📋 Recommended Best Practices

### 1. **SSH for Git Operations** ⭐ **RECOMMENDED**

**Why:**
- No credentials needed in URLs
- More secure
- Works reliably with port-forward
- Standard GitLab practice

**Setup:**
```bash
# Add SSH key to GitLab
./scripts/setup-ssh-access.sh

# Use SSH URLs
git remote add origin ssh://git@localhost:2222/group/repo.git
```

### 2. **Personal Access Tokens for Automation**

**For Scripts/CI/CD:**
- Use Personal Access Token (not passwords)
- Store in GitLab CI/CD Variables (masked)
- Use format: `http://oauth2:${TOKEN}@localhost:8080/group/repo.git`

**Why:**
- More secure than passwords
- Can be scoped (api, read_repository, write_repository)
- Can be revoked easily
- No special character encoding issues

### 3. **Port-Forward Management**

**Best Practice:**
- Use scripts to manage port-forwards
- Check if running before starting
- Run in background for convenience
- Document that they're not persistent

**Example:**
```bash
# Check and start if needed
./scripts/start-port-forward.sh
```

### 4. **Configuration Alignment**

**For Development:**
- Use `localhost:8080` in `external_url` if using port-forward
- OR use `gitlab.local` and accept port-forward URLs may differ

**For Production:**
- Use LoadBalancer/Ingress
- Set `external_url` to actual domain
- Use HTTPS with SSL certificates

---

## 🎯 Recommended Setup for Your Environment

### Current Setup (Development)

**Best Practice Configuration:**

1. **Keep current port-forward approach:**
   ```bash
   kubectl port-forward -n gitlab service/gitlab-service 8080:80 &
   kubectl port-forward -n gitlab service/gitlab-service 2222:2222 &
   ```

2. **Use SSH for git operations:**
   ```bash
   git remote add origin ssh://git@localhost:2222/group/repo.git
   ```

3. **Use localhost:8080 for browser:**
   ```
   http://localhost:8080
   ```

4. **Optionally update external_url:**
   ```yaml
   # In k8s/configmap.yaml
   external_url 'http://localhost:8080'
   ```
   This makes GitLab generate correct URLs.

### Future Production Setup

**When ready for production:**

1. **Change service to LoadBalancer:**
   ```yaml
   # In k8s/service.yaml
   spec:
     type: LoadBalancer
   ```

2. **Update external_url:**
   ```yaml
   # In k8s/configmap.yaml
   external_url 'https://gitlab.yourdomain.com'
   ```

3. **Configure DNS:**
   - Point `gitlab.yourdomain.com` to LoadBalancer IP

4. **Add SSL/TLS:**
   - Configure certificates in GitLab

---

## 📊 Comparison: Access Methods

| Method | Use Case | Pros | Cons |
|--------|----------|------|------|
| **SSH (localhost:2222)** | Git operations | ✅ No credentials<br>✅ Secure<br>✅ Standard | Requires port-forward |
| **HTTP (localhost:8080)** | Git operations | ✅ Simple<br>✅ Works with port-forward | Requires credentials<br>Password in URL |
| **HTTP (gitlab.local:8080)** | Git operations | Matches config | ⚠️ GitLab may reject |
| **HTTP (gitlab.local:80)** | Git operations | Matches config | ❌ Not accessible |
| **LoadBalancer** | Production | ✅ No port-forward<br>✅ Accessible externally | Requires setup |

---

## ✅ Recommended Best Practices Summary

### For Development (Current Setup)

1. ✅ **Use SSH for git operations** - `ssh://git@localhost:2222/group/repo.git`
2. ✅ **Use localhost:8080 for browser** - `http://localhost:8080`
3. ✅ **Use Personal Access Tokens** - For automation/scripts
4. ✅ **Add gitlab.local to /etc/hosts** - For consistency (optional)
5. ✅ **Use port-forward scripts** - Automate port-forward management

### For Production (Future)

1. ✅ **Use LoadBalancer or Ingress** - Proper external access
2. ✅ **Configure proper DNS** - `gitlab.yourdomain.com`
3. ✅ **Use HTTPS** - SSL/TLS certificates
4. ✅ **Update external_url** - Match actual domain
5. ✅ **Use SSH for git** - Still recommended

---

## 🔧 Quick Fix for Current Issue

**To fix the repository access issue:**

**Option 1: Use SSH (Recommended)**
```bash
cd /Users/eric/Documents/Scripts/browser/Google-Workspace-Forensics-Investigator
git remote remove origin
git remote add origin ssh://git@localhost:2222/open-source-development/google-workspace-forensics-investigator.git
git push --force origin main
```

**Option 2: Use HTTP with Token**
```bash
# Get token from: http://localhost:8080/-/user_settings/personal_access_tokens
GITLAB_TOKEN="your_token_here"
git remote add origin http://oauth2:${GITLAB_TOKEN}@localhost:8080/open-source-development/google-workspace-forensics-investigator.git
git push --force origin main
```

**Option 3: Use HTTP with Root Password (URL encoded)**
```bash
PASSWORD="ChangeMe123!@#SecurePassword"
ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$PASSWORD'))")
git remote add origin http://root:${ENCODED}@localhost:8080/open-source-development/google-workspace-forensics-investigator.git
git push --force origin main
```

---

**Last Updated:** November 5, 2025  
**Status:** Best practices documented for Kubernetes deployment with port-forward


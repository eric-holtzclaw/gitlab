# GitLab SSH Keys - Where Are They?

**Last Updated:** November 5, 2025

---

## 📍 SSH Key Locations

### 1. **Local SSH Keys** (Your Machine)

**Location:** `~/.ssh/` directory

**Your SSH Keys:**
- `~/.ssh/id_ed25519.pub` - Primary SSH key (ed25519)
- `~/.ssh/gitlab_deploy_key.pub` - GitLab deploy key
- `~/.ssh/ha_eric.pub` - HA-specific key
- `~/.ssh/id_ed25519_github.pub` - GitHub key

**View your keys:**
```bash
# List all public keys
ls -la ~/.ssh/*.pub

# View a specific key
cat ~/.ssh/id_ed25519.pub

# View private key (be careful!)
cat ~/.ssh/id_ed25519
```

**Generate a new key (if needed):**
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

---

### 2. **SSH Keys Stored in GitLab**

#### User SSH Keys (Global)

**UI Location:** http://localhost:8080/-/profile/keys

**API Endpoint:** `GET /api/v4/user/keys`

**View via API:**
```bash
curl -H "PRIVATE-TOKEN: YOUR_TOKEN" \
  http://localhost:8080/api/v4/user/keys
```

**Add via API:**
```bash
curl -X POST \
  -H "PRIVATE-TOKEN: YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"My Key","key":"ssh-ed25519 AAAA..."}' \
  http://localhost:8080/api/v4/user/keys
```

#### Project Deploy Keys (Per-Repository)

**UI Location:** http://localhost:8080/[group]/[project]/-/settings/repository#js-deploy-keys

**Example:** http://localhost:8080/open-source-development/google-workspace-forensics-investigator/-/settings/repository#js-deploy-keys

**API Endpoint:** `GET /api/v4/projects/[id]/deploy_keys`

**View via API:**
```bash
# Get project ID first
PROJECT_ID=6  # Replace with actual project ID
curl -H "PRIVATE-TOKEN: YOUR_TOKEN" \
  http://localhost:8080/api/v4/projects/${PROJECT_ID}/deploy_keys
```

**Add deploy key via API:**
```bash
curl -X POST \
  -H "PRIVATE-TOKEN: YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Deploy Key","key":"ssh-ed25519 AAAA...","can_push":true}' \
  http://localhost:8080/api/v4/projects/${PROJECT_ID}/deploy_keys
```

---

## 🔧 SSH Key Management Scripts

**Location:** `GitLab/scripts/`

### Available Scripts:

1. **`setup-ssh-access.sh`** - Full-featured SSH setup
   - Finds your SSH key automatically
   - Adds it to GitLab via API
   - Tests the connection
   - Shows usage examples

2. **`add-ssh-key-simple.sh`** - Simple SSH key addition
   - Just adds your SSH key to GitLab
   - Minimal output

**Run setup:**
```bash
cd /Users/eric/Documents/Scripts/infrastructure/gitlab
./scripts/setup-ssh-access.sh
```

---

## 📋 SSH Key Types

### User SSH Keys
- **Global** - Work for all repositories you have access to
- **Personal** - Tied to your user account
- **Full Access** - Can push/pull to any repository you have access to

### Deploy Keys
- **Per-Project** - Only work for one specific repository
- **Limited** - Can be read-only or read-write
- **CI/CD** - Often used for automated deployments

---

## 🔍 How to Check Which Keys Are in GitLab

### Via UI:
1. Go to: http://localhost:8080/-/profile/keys
2. You'll see all your user SSH keys
3. For deploy keys, go to project settings

### Via API:
```bash
# User keys
curl -H "PRIVATE-TOKEN: YOUR_TOKEN" \
  http://localhost:8080/api/v4/user/keys | jq

# Deploy keys (for specific project)
PROJECT_ID=6
curl -H "PRIVATE-TOKEN: YOUR_TOKEN" \
  http://localhost:8080/api/v4/projects/${PROJECT_ID}/deploy_keys | jq
```

### Via SSH Test:
```bash
# Test SSH connection (will show which key GitLab sees)
ssh -T -p 2222 git@localhost
```

**Expected output:**
```
Welcome to GitLab, @root!
```

---

## 🚀 Quick Reference

**Local Keys Location:**
```bash
~/.ssh/
```

**GitLab User Keys (UI):**
```
http://localhost:8080/-/profile/keys
```

**GitLab Deploy Keys (UI):**
```
http://localhost:8080/[group]/[project]/-/settings/repository#js-deploy-keys
```

**GitLab User Keys (API):**
```
GET http://localhost:8080/api/v4/user/keys
```

**GitLab Deploy Keys (API):**
```
GET http://localhost:8080/api/v4/projects/[id]/deploy_keys
```

---

## 📝 Notes

- **Private keys** (`~/.ssh/id_ed25519`) should **NEVER** be shared or committed
- **Public keys** (`~/.ssh/id_ed25519.pub`) are safe to share and add to GitLab
- Deploy keys are project-specific and can be read-only or read-write
- User SSH keys work globally across all repositories you have access to

---

**Related Documentation:**
- [SSH_ACCESS_GUIDE.md](SSH_ACCESS_GUIDE.md) - Complete SSH setup guide
- [BEST_PRACTICES_GITLAB_ACCESS.md](BEST_PRACTICES_GITLAB_ACCESS.md) - SSH best practices
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - New user setup instructions


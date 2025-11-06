# SSH Access Setup - Complete

**Date:** November 4, 2025  
**Status:** ✅ Scripts Ready - Ready to Execute

---

## 🚀 Quick Setup

I've created automated scripts to set up SSH access. Run:

```bash
cd /Users/ericholtzclaw/Scripts/browser/GitLab

# Option 1: Full-featured script
./scripts/setup-ssh-access.sh

# Option 2: Simple script
./scripts/add-ssh-key-simple.sh
```

---

## ✅ What the Scripts Do

1. **Find your SSH public key** (automatically detects `~/.ssh/id_ed25519.pub` or `~/.ssh/id_rsa.pub`)
2. **Add it to GitLab** via API (using your Personal Access Token)
3. **Test the connection** (if SSH port-forward is running)
4. **Show usage examples**

---

## 📋 Manual Setup (Alternative)

If you prefer to do it manually:

### 1. Get Your SSH Public Key

```bash
cat ~/.ssh/id_ed25519.pub
# or
cat ~/.ssh/id_rsa.pub
```

### 2. Add to GitLab via UI

1. Go to: http://localhost:8080/-/profile/keys
2. Click **"Add new key"**
3. Paste your public key
4. Give it a title (e.g., "MacBook Pro")
5. Click **"Add key"**

### 3. Start SSH Port-Forward

```bash
kubectl port-forward -n gitlab service/gitlab-service 2222:2222
```

### 4. Test Connection

```bash
ssh -T -p 2222 git@localhost
```

**Expected output:**
```
Welcome to GitLab, @root!
```

---

## 🎯 Using GitLab SSH

Once SSH is set up, you can use it like GitHub:

### Clone Repository

```bash
git clone ssh://git@localhost:2222/infrastructure/core.git
```

### Add Remote

```bash
git remote add gitlab ssh://git@localhost:2222/infrastructure/core.git
```

### Push/Pull

```bash
git push gitlab main
git pull gitlab main
```

---

## 📝 SSH URL Format

```
ssh://git@localhost:2222/GROUP/PROJECT.git
```

**Examples:**
- `ssh://git@localhost:2222/infrastructure/core.git`
- `ssh://git@localhost:2222/forensics/o365-forensics-investigator.git`
- `ssh://git@localhost:2222/automation/n8n.git`

---

## 🔍 Verify SSH Keys

Check your SSH keys in GitLab:

```bash
# Via API
curl -s --header "PRIVATE-TOKEN: glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3" \
  "http://localhost:8080/api/v4/user/keys" | python3 -m json.tool
```

Or visit: http://localhost:8080/-/profile/keys

---

## 🛠️ Troubleshooting

### "Connection refused" on port 2222

**Solution:** Start SSH port-forward:
```bash
kubectl port-forward -n gitlab service/gitlab-service 2222:2222
```

### "Permission denied (publickey)"

**Solution:** Make sure your SSH key is added to GitLab:
- Run the setup script, or
- Add it manually via UI

### "Host key verification failed"

**Solution:** Add to known_hosts:
```bash
ssh-keyscan -p 2222 localhost >> ~/.ssh/known_hosts
```

---

## ✅ Status

**Scripts Created:**
- ✅ `scripts/setup-ssh-access.sh` - Full-featured with testing
- ✅ `scripts/add-ssh-key-simple.sh` - Simple version

**Documentation:**
- ✅ `SSH_ACCESS_GUIDE.md` - Complete guide
- ✅ `README.md` - Updated with SSH section

**Configuration:**
- ✅ GitLab SSH port 2222 configured
- ✅ Service exposes SSH port
- ✅ Ready to accept SSH keys

---

**Next Step:** Run the setup script to add your SSH key! 🚀




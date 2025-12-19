# GitLab Setup Guide for New Users

**Purpose:** Complete setup instructions for new users to access and use GitLab on Mac, Linux, and Windows.

**Prerequisites:** GitLab must already be deployed and running in Kubernetes.

---

## 🎯 Quick Start Checklist

- [ ] Add `gitlab.local` to `/etc/hosts` (or Windows `hosts` file)
- [ ] Start port-forward for GitLab access
- [ ] Add SSH key to GitLab (optional, for SSH access)
- [ ] Test access via browser
- [ ] Test git operations

---

## 📋 Platform-Specific Setup

### macOS Setup

#### 1. Add gitlab.local to hosts file

**Open Terminal and run:**
```bash
sudo bash -c 'echo "127.0.0.1 gitlab.local" >> /etc/hosts'
```

**Verify it was added:**
```bash
grep gitlab.local /etc/hosts
```

**Expected output:**
```
127.0.0.1 gitlab.local
```

**Note:** This change is **persistent** - it survives reboots. The `/etc/hosts` file is part of the system configuration.

#### 2. Start port-forward

**HTTP/HTTPS (for browser access):**
```bash
kubectl port-forward -n gitlab service/gitlab-service 8080:80
```

**SSH (for git operations, in another terminal):**
```bash
kubectl port-forward -n gitlab service/gitlab-service 2222:2222
```

**Or use the automated script:**
```bash
cd /Users/eric/Documents/Scripts/infrastructure/gitlab
./scripts/start-port-forward.sh
```

#### 3. Access GitLab

- **Browser:** http://localhost:8080
- **Default username:** `root`
- **Password:** Check `k8s/secret.yaml` or `token_vault.json`

#### 4. Add SSH Key (Optional, for SSH git access)

**Generate SSH key (if you don't have one):**
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

**Add SSH key to GitLab:**
1. Go to: http://localhost:8080/-/profile/keys
2. Click "Add new key"
3. Paste your public key:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
4. Give it a title (e.g., "MacBook Pro")
5. Click "Add key"

**Test SSH connection:**
```bash
ssh -T -p 2222 git@gitlab.local
```

**Expected output:**
```
Welcome to GitLab, @root!
```

---

### Linux Setup

#### 1. Add gitlab.local to hosts file

**Open Terminal and run:**
```bash
sudo bash -c 'echo "127.0.0.1 gitlab.local" >> /etc/hosts'
```

**Verify it was added:**
```bash
grep gitlab.local /etc/hosts
```

**Expected output:**
```
127.0.0.1 gitlab.local
```

**Note:** This change is **persistent** - it survives reboots. The `/etc/hosts` file is part of the system configuration.

#### 2. Start port-forward

**HTTP/HTTPS (for browser access):**
```bash
kubectl port-forward -n gitlab service/gitlab-service 8080:80
```

**SSH (for git operations, in another terminal):**
```bash
kubectl port-forward -n gitlab service/gitlab-service 2222:2222
```

**Or use the automated script:**
```bash
cd /path/to/GitLab
./scripts/start-port-forward.sh
```

#### 3. Access GitLab

- **Browser:** http://localhost:8080
- **Default username:** `root`
- **Password:** Check `k8s/secret.yaml` or `token_vault.json`

#### 4. Add SSH Key (Optional, for SSH git access)

**Generate SSH key (if you don't have one):**
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

**Add SSH key to GitLab:**
1. Go to: http://localhost:8080/-/profile/keys
2. Click "Add new key"
3. Paste your public key:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
4. Give it a title (e.g., "Linux Workstation")
5. Click "Add key"

**Test SSH connection:**
```bash
ssh -T -p 2222 git@gitlab.local
```

**Expected output:**
```
Welcome to GitLab, @root!
```

---

### Windows Setup

#### 1. Add gitlab.local to hosts file

**Option A: Using PowerShell (Run as Administrator)**

1. Open PowerShell as Administrator
2. Run:
   ```powershell
   Add-Content -Path "$env:windir\System32\drivers\etc\hosts" -Value "`n127.0.0.1 gitlab.local" -Force
   ```

**Option B: Manual Edit**

1. Open Notepad as Administrator
   - Right-click Notepad → "Run as administrator"
2. Open file: `C:\Windows\System32\drivers\etc\hosts`
3. Add this line at the end:
   ```
   127.0.0.1 gitlab.local
   ```
4. Save the file

**Verify it was added:**
```powershell
Get-Content "$env:windir\System32\drivers\etc\hosts" | Select-String "gitlab.local"
```

**Expected output:**
```
127.0.0.1 gitlab.local
```

**Note:** This change is **persistent** - it survives reboots. The `hosts` file is part of the system configuration.

#### 2. Start port-forward

**HTTP/HTTPS (for browser access):**
```powershell
kubectl port-forward -n gitlab service/gitlab-service 8080:80
```

**SSH (for git operations, in another PowerShell window):**
```powershell
kubectl port-forward -n gitlab service/gitlab-service 2222:2222
```

**Note:** Keep these PowerShell windows open while using GitLab.

#### 3. Access GitLab

- **Browser:** http://localhost:8080
- **Default username:** `root`
- **Password:** Check `k8s/secret.yaml` or `token_vault.json`

#### 4. Add SSH Key (Optional, for SSH git access)

**Generate SSH key (if you don't have one):**

**Using Git Bash or PowerShell:**
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

**Windows Location:** `C:\Users\YourUsername\.ssh\id_ed25519.pub`

**Add SSH key to GitLab:**
1. Go to: http://localhost:8080/-/profile/keys
2. Click "Add new key"
3. Paste your public key:
   ```powershell
   Get-Content C:\Users\YourUsername\.ssh\id_ed25519.pub
   ```
4. Give it a title (e.g., "Windows PC")
5. Click "Add key"

**Test SSH connection (using Git Bash or WSL):**
```bash
ssh -T -p 2222 git@gitlab.local
```

**Expected output:**
```
Welcome to GitLab, @root!
```

**Note:** Windows users may prefer HTTP git access instead of SSH:
```bash
git remote add origin http://gitlab.local/group/repo.git
```

---

## 🔧 Using GitLab After Setup

### Clone a Repository

**HTTP (works on all platforms):**
```bash
git clone http://gitlab.local/development/google-workspace-forensics-investigator.git
```

**SSH (requires SSH key setup):**
```bash
git clone ssh://git@gitlab.local:2222/development/google-workspace-forensics-investigator.git
```

### Add Remote to Existing Repository

**HTTP:**
```bash
git remote add origin http://gitlab.local/development/repo-name.git
```

**SSH:**
```bash
git remote add origin ssh://git@gitlab.local:2222/development/repo-name.git
```

### Push to GitLab

```bash
git branch -M main
git push -uf origin main
```

---

## 🛠️ Troubleshooting

### Issue: "Could not resolve host: gitlab.local"

**Solution:** Verify hosts file entry

**macOS/Linux:**
```bash
grep gitlab.local /etc/hosts
```

**Windows:**
```powershell
Get-Content "$env:windir\System32\drivers\etc\hosts" | Select-String "gitlab.local"
```

**If missing, add it:**
- macOS/Linux: `sudo bash -c 'echo "127.0.0.1 gitlab.local" >> /etc/hosts'`
- Windows: Add `127.0.0.1 gitlab.local` to `C:\Windows\System32\drivers\etc\hosts`

### Issue: "Connection refused" when accessing http://localhost:8080

**Solution:** Start port-forward
```bash
kubectl port-forward -n gitlab service/gitlab-service 8080:80
```

**Verify it's running:**
```bash
# macOS/Linux
lsof -i :8080

# Windows PowerShell
netstat -ano | findstr :8080
```

### Issue: SSH connection fails ("Connection refused")

**Solution:** Start SSH port-forward
```bash
kubectl port-forward -n gitlab service/gitlab-service 2222:2222
```

### Issue: "Permission denied (publickey)" for SSH

**Solution:** 
1. Verify SSH key is added to GitLab: http://localhost:8080/-/profile/keys
2. Test SSH connection: `ssh -T -p 2222 git@gitlab.local`
3. If still failing, re-add SSH key to GitLab

### Issue: Changes to hosts file don't persist after reboot

**This shouldn't happen** - `/etc/hosts` (macOS/Linux) and `hosts` (Windows) are system files that persist across reboots.

**If it happens:**
1. Verify you edited the correct file (system hosts file, not a user copy)
2. Check file permissions (should be readable by system)
3. On Windows, ensure you edited as Administrator

---

## 📋 Summary: What Each Platform Needs

### macOS
- ✅ Add `127.0.0.1 gitlab.local` to `/etc/hosts` (one-time, persistent)
- ✅ Start port-forward (8080 for HTTP, 2222 for SSH)
- ✅ Optional: Add SSH key to GitLab

### Linux
- ✅ Add `127.0.0.1 gitlab.local` to `/etc/hosts` (one-time, persistent)
- ✅ Start port-forward (8080 for HTTP, 2222 for SSH)
- ✅ Optional: Add SSH key to GitLab

### Windows
- ✅ Add `127.0.0.1 gitlab.local` to `C:\Windows\System32\drivers\etc\hosts` (one-time, persistent)
- ✅ Start port-forward (8080 for HTTP, 2222 for SSH)
- ✅ Optional: Add SSH key to GitLab (or use HTTP git access)

---

## 🔄 Persistent Setup (Survives Reboots)

### Hosts File Entry
- **macOS/Linux:** `/etc/hosts` - System file, automatically persists
- **Windows:** `C:\Windows\System32\drivers\etc\hosts` - System file, automatically persists

### Port-Forward (Not Persistent)
Port-forwards are **not persistent** - they need to be restarted after each reboot or terminal session.

**Solutions:**
1. **Manual:** Run `kubectl port-forward` commands when needed
2. **Script:** Use `./scripts/start-port-forward.sh` (if available)
3. **Background:** Run port-forward in background or use screen/tmux
4. **Automation:** Set up a startup script or service (advanced)

**Example: Run port-forward in background (macOS/Linux):**
```bash
kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /dev/null 2>&1 &
kubectl port-forward -n gitlab service/gitlab-service 2222:2222 > /dev/null 2>&1 &
```

---

## 📚 Related Documentation

- **SSH Access:** [SSH_ACCESS_GUIDE.md](SSH_ACCESS_GUIDE.md)
- **Change Tracking:** [CHANGELOG.md](CHANGELOG.md)
- **CFORD Compliance:** [CFORD_COMPLIANCE.md](CFORD_COMPLIANCE.md)
- **Main README:** [README.md](README.md)

---

**Last Updated:** 2025-11-04  
**Maintained By:** GitLab Repository Team


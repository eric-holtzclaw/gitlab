# Repository Import Solution

**Issue:** Git push commands not working due to password special characters  
**Solution:** Use Personal Access Token (PAT)

---

## 🎯 Quick Fix

### Step 1: Create Personal Access Token

1. Open: http://localhost:8080/-/user_settings/personal_access_tokens
2. Click **"Add new token"**
3. Fill in:
   - **Token name:** `import-repositories`
   - **Expiration date:** (optional)
   - **Scopes:** Check:
     - ✅ `api`
     - ✅ `write_repository`
     - ✅ `read_repository`
4. Click **"Create personal access token"**
5. **Copy the token immediately** (you won't see it again!)

### Step 2: Run Import Script

```bash
cd /Users/ericholtzclaw/Scripts/browser/GitLab

# Set your token (replace YOUR_TOKEN with the token you copied)
export GITLAB_TOKEN="YOUR_TOKEN"

# Run the import script
./scripts/import-with-token.sh
```

---

## 🔍 Why This Works

- **Password in URL:** `ChangeMe123!@#SecurePassword` has special characters that break Git URLs
- **Token in URL:** Personal Access Tokens are designed for programmatic access
- **Force flag:** `--force` overwrites the initial README commit

---

## 📋 What Gets Imported

✅ **Infrastructure:**
- core
- supabase
- nginx
- gitlab

✅ **Forensics:**
- O365-Forensics-Investigator

✅ **Automation:**
- N8N

✅ **Development:**
- kali

---

## ✅ After Import

1. Verify repositories have content (not just README)
2. Set up mirroring for core, supabase, nginx
3. Fix Google-Workspace-Forensics-Investigator location

---

**This is the recommended approach for importing repositories!**



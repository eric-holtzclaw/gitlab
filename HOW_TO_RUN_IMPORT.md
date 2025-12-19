# How to Run the Import Script

**Date:** November 4, 2025  
**Status:** ✅ Script fixed - Ready to run with GitHub token

---

## ✅ What Was Fixed

1. **Added GitHub authentication** - Now uses `GITHUB_TOKEN` environment variable
2. **Skip empty repos** - Won't try to push empty repositories (like gitlab)
3. **Better error handling** - Clearer error messages

---

## 🚀 How to Run

### Step 1: Create GitHub Personal Access Token

1. Go to: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Name: `gitlab-import`
4. Scopes: Check `repo` (for private repositories)
5. Click "Generate token"
6. **Copy the token** (you won't see it again!)

### Step 2: Set the Token and Run

```bash
# Set GitHub token
export GITHUB_TOKEN='your_token_here'

# Navigate to GitLab directory
cd /Users/eric/Documents/Scripts/infrastructure/gitlab

# Ensure port-forward is running
kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /dev/null 2>&1 &

# Run the import script
./scripts/run-import.sh
```

### Step 3: Watch the Output

The script will:
- Show progress for each repository
- Display success/failure messages
- Log everything to `/tmp/gitlab-import-run.log`

---

## 📋 What Gets Imported

- ✅ core (Infrastructure)
- ✅ supabase (Infrastructure)
- ✅ nginx (Infrastructure)
- ⚠️ gitlab (Infrastructure - empty, will skip)
- ✅ O365-Forensics-Investigator (Forensics)
- ✅ N8N (Automation)
- ✅ kali (Development)

---

## ✅ Success Indicators

After successful import, check:
- http://localhost:8080/infrastructure/core/-/commits/main
- Should show multiple commits (not just "Initial commit")
- All files from GitHub should be visible

---

## ❌ If It Still Fails

1. **Check port-forward:**
   ```bash
   lsof -i :8080
   ```

2. **Check log file:**
   ```bash
   cat /tmp/gitlab-import-run.log
   ```

3. **Verify token:**
   ```bash
   echo $GITHUB_TOKEN
   ```

4. **Test GitHub access manually:**
   ```bash
   git clone --mirror "https://${GITHUB_TOKEN}@github.com/eric-holtzclaw/core.git" /tmp/test-core.git
   ```

---

**Ready to import!** Just set `GITHUB_TOKEN` and run the script. 🎉



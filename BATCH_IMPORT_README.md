# Batch Import Script

**Location:** `scripts/batch-import.sh`

**Purpose:** Import all repositories from GitHub to GitLab in one batch operation.

---

## 🚀 Quick Start

```bash
cd /Users/eric/Documents/Scripts/infrastructure/gitlab
./scripts/batch-import.sh
```

That's it! The script handles everything automatically.

---

## 📋 What It Does

1. **Checks port-forward** - Automatically starts GitLab port-forward if needed
2. **Imports 8 repositories:**
   - **Infrastructure:** core, supabase, nginx, gitlab
   - **Forensics:** o365-forensics-investigator
   - **Automation:** n8n
   - **Development:** kali

3. **Shows progress** - Displays commit counts and branch counts for each repo
4. **Provides summary** - Shows success/failure count at the end

---

## 🔧 How It Works

- Uses Personal Access Token: `glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3`
- Clones each repository with `--mirror` (preserves all branches/tags)
- Pushes with `--force` to overwrite initial README commits
- Uses `oauth2:TOKEN` format to avoid URL encoding issues

---

## 📊 Expected Output

```
=========================================
GitLab Batch Repository Import
=========================================

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Importing: core
  From: https://github.com/eric-holtzclaw/core.git
  To: infrastructure/core

  Cloning from GitHub...
  ✅ Cloned: 150 commits, 3 branches
  Pushing to GitLab...
  ✅ Successfully imported core

... (continues for all repos)

=========================================
Import Summary
=========================================
✅ Success: 8
View repositories at: http://localhost:8080
```

---

## ⚠️ Troubleshooting

**If imports fail:**
1. Check GitLab is running: `kubectl get pods -n gitlab`
2. Check port-forward: `lsof -i :8080`
3. Verify token is still valid in GitLab UI
4. Check log file: `/tmp/batch-import-output.log`

**If repository still shows only "Initial commit":**
- The push may have failed silently
- Check individual push logs: `/tmp/git-push-<repo-name>.log`
- Try running the script again (it's idempotent)

---

## 🔄 Re-running

The script is safe to run multiple times. It will:
- Re-clone fresh copies from GitHub
- Force push to overwrite any existing content
- Show progress for each repository

---

**Created:** November 4, 2025  
**Status:** ✅ Ready to use



# Fix Repository Access - Research-Based Solutions

**Issue:** Repository exists in GitLab UI but git push fails with "project not found"

**Date:** November 5, 2025

---

## 🔍 Root Cause Analysis

Based on research and testing:

1. ✅ **SSH Authentication Works** - `ssh -T git@localhost` succeeds
2. ✅ **Repository Exists in UI** - Shows at http://localhost:8080/open-source-development/google-workspace-forensics-investigator
3. ✅ **Repository Has Content** - Shows initial README file
4. ❌ **Git Can't Access** - "The project you were looking for could not be found"

**Most Likely Cause:** Repository path mismatch between UI display and actual git path.

---

## 🔧 Solutions (In Order of Likelihood)

### Solution 1: Get Exact Clone URL from GitLab UI ⭐ **RECOMMENDED**

The UI shows the repository, but the actual git path might be different.

**Steps:**
1. Open repository in GitLab: http://localhost:8080/open-source-development/google-workspace-forensics-investigator
2. Click the blue **"Clone"** button (top right)
3. Copy the **exact SSH URL** shown (e.g., `ssh://git@localhost:2222/[exact-path].git`)
4. Use that exact URL:
   ```bash
   cd /Users/eric/Documents/Scripts/browser/Google-Workspace-Forensics-Investigator
   git remote remove origin
   git remote add origin [exact-ssh-url-from-clone-button]
   git push --force origin main
   ```

**Why this works:** The Clone button shows the actual git path that GitLab uses internally, which may differ from the UI path.

---

### Solution 2: Repository Still at Original Path

The group was renamed from "development" to "open-source-development" in the UI, but the git path might still be `development`.

**Try:**
```bash
cd /Users/eric/Documents/Scripts/browser/Google-Workspace-Forensics-Investigator
git remote remove origin
git remote add origin ssh://git@localhost:2222/development/google-workspace-forensics-investigator.git
git push --force origin main
```

---

### Solution 3: Repository Name Case Sensitivity

GitLab is case-sensitive. The repository name might be:
- `Google-Workspace-Forensics-Investigator` (with capitals)
- `google-workspace-forensics-investigator` (all lowercase)
- Something else

**Check exact name in UI URL** and use that exact case.

---

### Solution 4: Use HTTP with Root Credentials

If SSH path is wrong, try HTTP with credentials:

```bash
cd /Users/eric/Documents/Scripts/browser/Google-Workspace-Forensics-Investigator
git remote remove origin

# URL encode the password (contains !@#)
PASSWORD="ChangeMe123!@#SecurePassword"
ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$PASSWORD'))")

git remote add origin "http://root:${ENCODED}@localhost:8080/open-source-development/google-workspace-forensics-investigator.git"
git push --force origin main
```

---

### Solution 5: Repository Needs Initialization

Even though repository exists in UI, it might not be initialized for git operations.

**Fix:**
1. Go to repository in GitLab UI
2. Click "Upload file" or "Initialize repository"
3. Add any file (even a small one)
4. Then try pushing again

---

### Solution 6: Check Repository Permissions

The user might not have Developer/Maintainer role on the repository.

**Fix:**
1. Go to: http://localhost:8080/open-source-development/google-workspace-forensics-investigator/-/project_members
2. Verify you (root user) have Maintainer or Owner role
3. If not, add yourself with appropriate permissions

---

## 🔍 Diagnostic Commands

Run these to diagnose:

```bash
# 1. Test SSH connection
ssh -T -p 2222 git@localhost

# 2. Check SSH keys in GitLab
curl -s --header "PRIVATE-TOKEN: YOUR_TOKEN" \
  http://localhost:8080/api/v4/user/keys | python3 -m json.tool

# 3. Try to list repository via API (if token works)
curl -s --header "PRIVATE-TOKEN: YOUR_TOKEN" \
  http://localhost:8080/api/v4/projects/open-source-development%2Fgoogle-workspace-forensics-investigator

# 4. Check repository via git ls-remote
git ls-remote ssh://git@localhost:2222/open-source-development/google-workspace-forensics-investigator.git
```

---

## ✅ Quick Fix Script

Created: `scripts/fix-repository-access.sh`

Run:
```bash
cd /Users/eric/Documents/Scripts/infrastructure/gitlab
./scripts/fix-repository-access.sh open-source-development/google-workspace-forensics-investigator
```

This script will:
- Check SSH key status
- Verify repository exists via API
- Check permissions
- Check branch protection
- Provide specific recommendations

---

## 📋 Current Status

- ✅ Files ready: `data-flow.drawio` + `README.md` (committed locally)
- ✅ SSH authentication working
- ✅ Repository visible in UI
- ⏳ Waiting for exact clone URL from GitLab UI to match git path

---

## 🎯 Next Steps

**Immediate:** Get the exact SSH clone URL from GitLab UI Clone button, then push.

**Long-term:** Update scripts to handle group renames properly (git path vs UI path).

---

**Last Updated:** November 5, 2025


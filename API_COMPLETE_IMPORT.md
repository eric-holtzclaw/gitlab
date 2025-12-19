# Complete Import via GitLab API

**Date:** November 4, 2025  
**Status:** ✅ Scripts Created - Ready to Use

---

## 📋 Available Scripts

### 1. `scripts/merge-via-api.sh` (Recommended)
**Purpose:** Unprotects branches, creates merge requests, and merges `github-import-main` into `main` via GitLab API.

**What it does:**
1. ✅ Unprotects `main` branch for each project
2. ✅ Finds or creates merge request from `github-import-main` → `main`
3. ✅ Merges the merge request automatically
4. ✅ Handles all 4 projects: core, supabase, O365-Forensics-Investigator, kali

**Usage:**
```bash
cd /Users/eric/Documents/Scripts/infrastructure/gitlab
bash scripts/merge-via-api.sh
```

**Projects processed:**
- `infrastructure/core`
- `infrastructure/supabase`
- `forensics/o365-forensics-investigator`
- `development/kali`

---

### 2. `scripts/complete-import-via-api.sh` (Full-featured)
**Purpose:** More comprehensive version with better error handling and logging.

**Usage:**
```bash
cd /Users/eric/Documents/Scripts/infrastructure/gitlab
bash scripts/complete-import-via-api.sh
```

---

## 🔧 API Endpoints Used

### 1. Unprotect Branch
```bash
DELETE /api/v4/projects/{project_id}/protected_branches/{branch_name}
```

### 2. Create Merge Request
```bash
POST /api/v4/projects/{project_id}/merge_requests
{
  "source_branch": "github-import-main",
  "target_branch": "main",
  "title": "Import from GitHub"
}
```

### 3. Merge Merge Request
```bash
PUT /api/v4/projects/{project_id}/merge_requests/{mr_iid}/merge
{
  "merge_commit_message": "Merge GitHub import into main"
}
```

---

## ✅ Current Status

**Repository Content:** ✅ All content successfully imported to `github-import-main` branches
- `core`: 21 commits
- `supabase`: 14 commits  
- `O365-Forensics-Investigator`: 73 commits
- `kali`: 2 commits

**Next Step:** Run the merge script to move content from `github-import-main` to `main`

---

## 🚀 Quick Start

1. **Ensure GitLab port-forward is running:**
   ```bash
   kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /dev/null 2>&1 &
   ```

2. **Run the merge script:**
   ```bash
   cd /Users/eric/Documents/Scripts/infrastructure/gitlab
   bash scripts/merge-via-api.sh
   ```

3. **Verify in GitLab UI:**
   - http://localhost:8080/infrastructure/core/-/commits/main
   - Should show all 21 commits (not just "Initial commit")

---

## 📝 Notes

- The script uses Personal Access Token: `glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3`
- All operations are done via GitLab REST API v4
- The script automatically handles existing merge requests
- After merge, `github-import-main` branch will be automatically deleted (if `remove_source_branch: true`)

---

**Last Updated:** November 4, 2025




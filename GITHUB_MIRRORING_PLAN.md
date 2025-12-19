# GitHub Mirroring Plan

**Date:** November 4, 2025  
**Status:** Ready for Review

---

## 📋 Repositories Planned for GitHub Mirroring

### Mirror Configuration: **Push Mirror (One-Way)**
- **Direction:** GitLab → GitHub
- **Type:** Push mirror (GitLab is primary, GitHub is backup)
- **Trigger:** Automatic on every push to GitLab

---

## ✅ Repositories to Mirror

### 1. **infrastructure/core**
- **GitLab:** `http://localhost:8080/infrastructure/core`
- **GitHub:** `https://github.com/eric-holtzclaw/core.git`
- **Status:** ✅ Ready
- **Commits:** 21 commits
- **Purpose:** Main Kubernetes DevOps tools

### 2. **infrastructure/supabase**
- **GitLab:** `http://localhost:8080/infrastructure/supabase`
- **GitHub:** `https://github.com/eric-holtzclaw/supabase.git`
- **Status:** ✅ Ready
- **Commits:** 14 commits
- **Purpose:** Supabase backend deployment

### 3. **infrastructure/nginx**
- **GitLab:** `http://localhost:8080/infrastructure/nginx`
- **GitHub:** `https://github.com/eric-holtzclaw/Nginx.git`
- **Status:** ✅ Ready
- **Commits:** 0 commits (empty repository)
- **Purpose:** Nginx reverse proxy configuration

---

## ❌ Repositories NOT Mirrored

### Explicitly Excluded:
- **applications/gmaxgolfapp** - Excluded as requested

### Other Repositories (GitLab Only):
- **infrastructure/gitlab** - Empty repository, self-tracking
- **microsoft-development/O365-Forensics-Investigator** - GitLab primary
- **microsoft-development/Google-Workspace-Forensics-Investigator** - GitLab primary
- **automation/N8N** - GitLab primary
- **open-source-development/kali** - GitLab primary
- **open-source-development/browser-lockdown** - GitLab primary
- **open-source-development/unified-wifi-scanner** - GitLab primary

---

## 🔄 Mirror Behavior

### What Gets Synced:
- ✅ All commits pushed to GitLab
- ✅ All branches (main, dev, feature branches, etc.)
- ✅ All tags
- ✅ All refs (full mirror)

### What Happens:
1. **Developer pushes to GitLab:**
   ```bash
   git push gitlab main
   ```

2. **GitLab automatically pushes to GitHub:**
   - Happens automatically after GitLab push
   - No manual intervention needed

3. **Result:**
   - GitHub repository stays in sync with GitLab
   - GitHub acts as backup/public mirror

### Settings:
- **Keep divergent refs:** ❌ No (GitLab content overwrites GitHub)
- **Only protected branches:** ❌ No (all branches mirrored)
- **Authentication:** GitHub Personal Access Token (PAT)

---

## ⚠️ Important Notes

### 1. One-Way Sync
- **GitLab is the source of truth**
- Changes made directly to GitHub will be overwritten
- Always push to GitLab, not GitHub

### 2. Authentication
- Requires GitHub Personal Access Token
- Token needs `repo` scope (full control of private repositories)
- Token is stored securely in GitLab (not in scripts)

### 3. Empty Repositories
- **nginx** is currently empty (0 commits)
- Mirroring will still be set up, but nothing to sync until content is added

---

## 🚀 Setup Process

### Prerequisites:
1. GitHub Personal Access Token with `repo` scope
2. GitHub repositories exist (they do)

### To Enable Mirroring:
```bash
export GITHUB_TOKEN=your_github_token
bash scripts/setup-github-mirroring.sh
```

### Manual Verification:
After setup, verify each mirror:
- http://localhost:8080/infrastructure/core/-/settings/repository#js-push-mirrors
- http://localhost:8080/infrastructure/supabase/-/settings/repository#js-push-mirrors
- http://localhost:8080/infrastructure/nginx/-/settings/repository#js-push-mirrors

---

## 📊 Summary

| Repository | GitLab Path | GitHub URL | Status | Commits |
|------------|-------------|------------|--------|---------|
| core | infrastructure/core | github.com/eric-holtzclaw/core.git | ✅ Ready | 21 |
| supabase | infrastructure/supabase | github.com/eric-holtzclaw/supabase.git | ✅ Ready | 14 |
| nginx | infrastructure/nginx | github.com/eric-holtzclaw/Nginx.git | ✅ Ready | 0 |

**Total Repositories to Mirror: 3**

---

## ✅ Approval Checklist

- [ ] Review repositories list above
- [ ] Confirm GitHub URLs are correct
- [ ] Verify GitHub repositories exist
- [ ] Confirm gmaxgolfapp exclusion
- [ ] Have GitHub Personal Access Token ready

**Ready to proceed when approved!**



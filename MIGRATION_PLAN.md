# GitLab Migration Plan

**Date:** November 2025  
**Strategy:** Mirror important repos, import others  
**Status:** 🚀 Ready to Execute

---

## 🎯 Migration Strategy

### **Mirror These (GitLab Primary, GitHub Backup)**
1. ✅ **core** - Critical infrastructure
2. ✅ **gmaxgolfapp** - Main application
3. ✅ **supabase** - Backend infrastructure
4. ✅ **nginx** - Infrastructure

### **Import These (GitLab Only)**
5. ✅ **O365-Forensics-Investigator** - Forensics tool
6. ✅ **Google-Workspace-Forensics-Investigator** - Forensics tool
7. ✅ **N8N** - Infrastructure tracking
8. ✅ **kali** - Dev environment
9. ✅ **gitlab** - Self-tracking

---

## 📋 Phase 1: Import Critical Repos (30 minutes)

### Step 1: Create GitLab Groups

1. **Access GitLab:**
   ```bash
   # Make sure port-forward is running
   kubectl port-forward -n gitlab service/gitlab-service 8080:80
   # Open: http://localhost:8080
   ```

2. **Create Groups:**
   - Go to **Groups** → **New Group**
   - Create groups:
     - `Infrastructure`
     - `Forensics`
     - `Applications`
     - `Automation`
     - `Development`

### Step 2: Import core Repository

1. **Go to Infrastructure group:**
   - Click **"New Project"** → **"Import project"**
   - Select **"Repository by URL"**
   - Enter: `https://github.com/eric-holtzclaw/core.git`
   - Project name: `core`
   - Visibility: Private
   - Click **"Create project"**

2. **Verify Import:**
   - Check that all files are imported
   - Verify commit history

### Step 3: Import gmaxgolfapp Repository

1. **Go to Applications group:**
   - Click **"New Project"** → **"Import project"**
   - Select **"Repository by URL"**
   - Enter: `https://github.com/eric-holtzclaw/gmaxgolfapp.git`
   - Project name: `gmaxgolfapp`
   - Visibility: Private
   - Click **"Create project"**

### Step 4: Import supabase Repository

1. **Go to Infrastructure group:**
   - Click **"New Project"** → **"Import project"**
   - Select **"Repository by URL"**
   - Enter: `https://github.com/eric-holtzclaw/supabase.git`
   - Project name: `supabase`
   - Visibility: Private
   - Click **"Create project"**

### Step 5: Import nginx Repository

1. **Go to Infrastructure group:**
   - Click **"New Project"** → **"Import project"**
   - Select **"Repository by URL"**
   - Enter: `https://github.com/eric-holtzclaw/Nginx.git`
   - Project name: `nginx`
   - Visibility: Private
   - Click **"Create project"**

---

## 📋 Phase 2: Set Up Mirroring (45 minutes)

### Prerequisites

1. **GitHub Personal Access Token:**
   - Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token with scopes:
     - `repo` (Full control of private repositories)
     - `workflow` (Update GitHub Action workflows)

### Step 1: Set Up Mirroring for core

1. **In GitLab (core project):**
   - Go to **Settings** → **Repository** → **Mirroring repositories**
   - Expand **"Push mirror"**
   - **Git repository URL:** `https://github.com/eric-holtzclaw/core.git`
   - **Mirror direction:** Push
   - **Authentication method:** Password
   - **Password:** `YOUR_GITHUB_TOKEN`
   - ✅ **Keep divergent refs:** Unchecked
   - Click **"Mirror repository"**

2. **Test Mirroring:**
   ```bash
   # Make a test commit in GitLab
   # Verify it appears in GitHub
   ```

### Step 2: Set Up Mirroring for gmaxgolfapp

1. **Same process as core:**
   - Settings → Repository → Mirroring repositories
   - Push mirror: `https://github.com/eric-holtzclaw/gmaxgolfapp.git`
   - Use same GitHub token

### Step 3: Set Up Mirroring for supabase

1. **Same process:**
   - Push mirror: `https://github.com/eric-holtzclaw/supabase.git`

### Step 4: Set Up Mirroring for nginx

1. **Same process:**
   - Push mirror: `https://github.com/eric-holtzclaw/Nginx.git`

---

## 📋 Phase 3: Import Remaining Repos (1 hour)

### Step 1: Import Forensics Repos

1. **O365-Forensics-Investigator:**
   - Group: `Forensics`
   - Import: `https://github.com/eric-holtzclaw/O365-Forensics-Investigator.git`
   - No mirroring needed

2. **Google-Workspace-Forensics-Investigator:**
   - Group: `Forensics`
   - Import: `https://github.com/eric-holtzclaw/Google-Workspace-Forensics-Investigator.git`
   - No mirroring needed

### Step 2: Import Automation Repos

1. **N8N:**
   - Group: `Automation`
   - Import: `https://github.com/eric-holtzclaw/N8N.git`
   - No mirroring needed

### Step 3: Import Development Repos

1. **kali:**
   - Group: `Development`
   - Import: `https://github.com/eric-holtzclaw/kali.git`
   - No mirroring needed

2. **gitlab:**
   - Group: `Infrastructure`
   - Import: `https://github.com/eric-holtzclaw/gitlab.git`
   - No mirroring needed (self-tracking)

---

## 🔧 Post-Migration Configuration

### For Each Mirrored Repository

1. **Update Local Remotes:**
   ```bash
   cd /path/to/repo
   git remote set-url origin git@localhost:2222:Infrastructure/core.git
   # Or use HTTPS: http://localhost:8080/Infrastructure/core.git
   ```

2. **Add CI/CD Pipeline:**
   - Add `.gitlab-ci.yml` to repository
   - Configure CI/CD variables in GitLab UI

3. **Test Workflow:**
   ```bash
   # Make a change
   git add .
   git commit -m "Test migration"
   git push origin main
   
   # Verify:
   # 1. Commit appears in GitLab
   # 2. Commit syncs to GitHub (if mirrored)
   # 3. CI/CD pipeline runs (if configured)
   ```

### Configure CI/CD Variables

For each project that needs CI/CD:

1. **Go to Project Settings → CI/CD → Variables**
2. **Add these variables:**
   - `K8S_SSH_KEY` - SSH key for K8s server (masked)
   - `K8S_CONFIG` - Base64 encoded kubeconfig (masked)
   - `DOCKERHUB_USER` - Docker Hub username
   - `DOCKERHUB_PASSWORD` - Docker Hub password (masked)
   - `GITHUB_TOKEN` - For mirroring (masked)

---

## ✅ Migration Checklist

### Phase 1: Critical Repos
- [ ] Create GitLab groups
- [ ] Import `core` repository
- [ ] Import `gmaxgolfapp` repository
- [ ] Import `supabase` repository
- [ ] Import `nginx` repository

### Phase 2: Mirroring Setup
- [ ] Create GitHub personal access token
- [ ] Configure push mirroring for `core`
- [ ] Configure push mirroring for `gmaxgolfapp`
- [ ] Configure push mirroring for `supabase`
- [ ] Configure push mirroring for `nginx`
- [ ] Test mirroring (make test commit)

### Phase 3: Remaining Repos
- [ ] Import `O365-Forensics-Investigator`
- [ ] Import `Google-Workspace-Forensics-Investigator`
- [ ] Import `N8N`
- [ ] Import `kali`
- [ ] Import `gitlab`

### Post-Migration
- [ ] Update local git remotes for mirrored repos
- [ ] Add `.gitlab-ci.yml` to critical repos
- [ ] Configure CI/CD variables
- [ ] Test push workflow
- [ ] Verify GitHub mirroring works
- [ ] Update documentation

---

## 🚨 Troubleshooting

### Mirroring Not Working

1. **Check Token:**
   - Verify GitHub token has `repo` scope
   - Check token hasn't expired

2. **Check URL:**
   - Use HTTPS URL: `https://github.com/eric-holtzclaw/repo.git`
   - Ensure repository exists and is accessible

3. **Check Logs:**
   - GitLab: Settings → Repository → Mirroring repositories → View logs

### Import Failed

1. **Check Repository Access:**
   - Ensure GitHub repository is accessible
   - Check if repository is private (may need token)

2. **Check GitLab Storage:**
   - Verify GitLab has enough storage
   - Check GitLab logs: `kubectl logs -n gitlab deployment/gitlab -f`

### CI/CD Not Running

1. **Check `.gitlab-ci.yml`:**
   - Verify syntax is correct
   - Check GitLab CI/CD documentation

2. **Check Variables:**
   - Ensure all required variables are set
   - Check variable names match pipeline

---

## 📊 Migration Status Tracking

| Repository | Phase | Status | Mirroring | CI/CD | Notes |
|------------|-------|--------|-----------|-------|-------|
| core | 1 | ⚠️ Pending | ✅ Yes | ✅ Yes | Critical |
| gmaxgolfapp | 1 | ⚠️ Pending | ✅ Yes | ✅ Yes | Critical |
| supabase | 1 | ⚠️ Pending | ✅ Yes | ✅ Yes | Critical |
| nginx | 1 | ⚠️ Pending | ✅ Yes | ✅ Yes | Critical |
| O365-Forensics | 3 | ⚠️ Pending | ❌ No | ⚠️ Optional | |
| Google-Workspace-Forensics | 3 | ⚠️ Pending | ❌ No | ⚠️ Optional | |
| N8N | 3 | ⚠️ Pending | ❌ No | ⚠️ Optional | |
| kali | 3 | ⚠️ Pending | ❌ No | ⚠️ Optional | |
| gitlab | 3 | ⚠️ Pending | ❌ No | ⚠️ Optional | |

**Legend:**
- ⚠️ Pending = Not started
- 🔄 In Progress = Currently working on
- ✅ Complete = Finished
- ❌ No = Not applicable
- ✅ Yes = Configured

---

## 🎯 Quick Reference: Repository URLs

### GitHub Repositories
- core: `https://github.com/eric-holtzclaw/core.git`
- gmaxgolfapp: `https://github.com/eric-holtzclaw/gmaxgolfapp.git`
- supabase: `https://github.com/eric-holtzclaw/supabase.git`
- nginx: `https://github.com/eric-holtzclaw/Nginx.git`
- O365-Forensics: `https://github.com/eric-holtzclaw/O365-Forensics-Investigator.git`
- Google-Workspace-Forensics: `https://github.com/eric-holtzclaw/Google-Workspace-Forensics-Investigator.git`
- N8N: `https://github.com/eric-holtzclaw/N8N.git`
- kali: `https://github.com/eric-holtzclaw/kali.git`
- gitlab: `https://github.com/eric-holtzclaw/gitlab.git`

### GitLab Project URLs (After Import)
- core: `http://localhost:8080/Infrastructure/core`
- gmaxgolfapp: `http://localhost:8080/Applications/gmaxgolfapp`
- supabase: `http://localhost:8080/Infrastructure/supabase`
- nginx: `http://localhost:8080/Infrastructure/nginx`
- (Similar pattern for others)

---

## 📝 Next Steps After Migration

1. **Update Local Git Remotes:**
   - Change origin to point to GitLab
   - Keep GitHub as backup remote (optional)

2. **Configure CI/CD:**
   - Add `.gitlab-ci.yml` to each project
   - Set up pipelines for automated deployment

3. **Team Communication:**
   - Update team on new GitLab location
   - Share access instructions

4. **Documentation:**
   - Update README files with new Git URLs
   - Document CI/CD processes

---

**Last Updated:** November 2025  
**Status:** ✅ Ready to Execute




# GitLab Migration Quick Start

**Time:** 30 minutes to get started  
**Status:** Ready to execute

---

## 🎯 What We're Doing

1. **Import 4 critical repos** to GitLab (mirror with GitHub)
2. **Import 5 other repos** to GitLab (GitLab only)
3. **Set up push mirroring** for critical repos
4. **Configure CI/CD** for automated deployments

---

## 📋 Step 1: Create GitLab Groups (5 minutes)

1. **Access GitLab:**
   ```bash
   # Make sure port-forward is running
   kubectl port-forward -n gitlab service/gitlab-service 8080:80
   # Open: http://localhost:8080
   ```

2. **Login:** root / [password from secret.yaml]

3. **Create Groups:**
   - Click **Groups** → **New Group**
   - Create:
     - `Infrastructure`
     - `Forensics`
     - `Applications`
     - `Automation`
     - `Development`

---

## 📋 Step 2: Import Critical Repos (15 minutes)

For each repository below, follow these steps:

1. Navigate to the appropriate group
2. Click **"New Project"** → **"Import project"**
3. Select **"Repository by URL"**
4. Enter the GitHub URL
5. Click **"Create project"**

### Repositories to Import:

#### Infrastructure Group:
1. **core**
   - URL: `https://github.com/eric-holtzclaw/core.git`
   
2. **supabase**
   - URL: `https://github.com/eric-holtzclaw/supabase.git`
   
3. **nginx**
   - URL: `https://github.com/eric-holtzclaw/Nginx.git`

#### Applications Group:
4. **gmaxgolfapp**
   - URL: `https://github.com/eric-holtzclaw/gmaxgolfapp.git`

---

## 📋 Step 3: Set Up Mirroring (15 minutes)

### Prerequisites:
1. **Create GitHub Token:**
   - Go to: https://github.com/settings/tokens
   - Generate new token (classic)
   - Scopes: `repo`
   - Copy token (save it!)

### Configure Mirroring:

For each repository (core, gmaxgolfapp, supabase, nginx):

1. Go to project in GitLab
2. **Settings** → **Repository** → **Mirroring repositories**
3. Expand **"Push mirror"**
4. Fill in:
   - **Git repository URL:** `https://github.com/eric-holtzclaw/REPO_NAME.git`
   - **Mirror direction:** Push
   - **Authentication method:** Password
   - **Password:** [Your GitHub token]
5. Click **"Mirror repository"**

### Test Mirroring:
```bash
# Make a test commit in GitLab
# Verify it appears in GitHub (should sync automatically)
```

---

## 📋 Step 4: Import Remaining Repos (30 minutes)

Import these to GitLab (no mirroring needed):

### Forensics Group:
- **O365-Forensics-Investigator**
  - URL: `https://github.com/eric-holtzclaw/O365-Forensics-Investigator.git`

- **Google-Workspace-Forensics-Investigator**
  - URL: `https://github.com/eric-holtzclaw/Google-Workspace-Forensics-Investigator.git`

### Automation Group:
- **N8N**
  - URL: `https://github.com/eric-holtzclaw/N8N.git`

### Development Group:
- **kali**
  - URL: `https://github.com/eric-holtzclaw/kali.git`

### Infrastructure Group:
- **gitlab**
  - URL: `https://github.com/eric-holtzclaw/gitlab.git`

---

## ✅ Verification Checklist

After migration, verify:

- [ ] All 9 repositories imported successfully
- [ ] 4 repositories have mirroring configured
- [ ] Test commit pushed to GitLab appears in GitHub (for mirrored repos)
- [ ] Can access all repositories via GitLab UI
- [ ] Local git remotes updated (optional)

---

## 🔧 Next Steps

1. **Update Local Git Remotes:**
   ```bash
   cd /path/to/repo
   git remote set-url origin git@localhost:2222:Group/repo.git
   ```

2. **Add CI/CD Pipelines:**
   - Add `.gitlab-ci.yml` to each project
   - Configure CI/CD variables

3. **Test Workflow:**
   ```bash
   git add .
   git commit -m "Test migration"
   git push origin main
   ```

---

## 📚 Documentation

- **Full Migration Plan:** `MIGRATION_PLAN.md`
- **Detailed Checklist:** `MIGRATION_CHECKLIST.md`
- **Project Structure:** `GITLAB_PROJECT_STRUCTURE.md`
- **Migration Helper:** `./scripts/migrate-to-gitlab.sh`

---

## 🆘 Need Help?

Run the migration helper:
```bash
cd GitLab
./scripts/migrate-to-gitlab.sh
```

This provides interactive guidance for each step.

---

**Ready to start?** Begin with Step 1 above! 🚀




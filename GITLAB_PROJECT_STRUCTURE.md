# GitLab Project Structure & Organization Plan

**Purpose:** Track all repositories and organize them in GitLab for CI/CD and version control  
**Date:** November 2025

---

## 🎯 GitLab Groups Organization

### Recommended Group Structure

```
GitLab Organization
├── Infrastructure/          # K8s, deployment tools, infrastructure
├── Forensics/              # Security investigation tools
├── Applications/           # Production applications
├── Automation/             # Workflow automation
├── Development/            # Development tools and utilities
└── Personal/              # Personal projects
```

---

## 📋 Projects to Create in GitLab

### Group: **Infrastructure** 🏗️

#### 1. **core** ⭐ (HIGH PRIORITY)
- **GitHub:** https://github.com/eric-holtzclaw/core
- **Purpose:** Kubernetes DevOps tools, main deployment scripts
- **CI/CD:** ✅ Yes (critical)
- **Why:** This is your main deployment infrastructure
- **Pipeline:** Build Docker images, deploy to K8s
- **Import:** Import from GitHub URL

#### 2. **gitlab**
- **GitHub:** https://github.com/eric-holtzclaw/gitlab
- **Purpose:** GitLab deployment manifests
- **CI/CD:** ⚠️ Optional (self-deployment)
- **Why:** Track GitLab infrastructure as code
- **Note:** This is the GitLab deployment itself

#### 3. **supabase**
- **GitHub:** https://github.com/eric-holtzclaw/supabase
- **Purpose:** Supabase backend deployment
- **CI/CD:** ✅ Yes (deploy databases for apps)
- **Why:** Infrastructure for multiple apps
- **Pipeline:** Deploy PostgreSQL databases for apps

#### 4. **nginx**
- **GitHub:** ✅ https://github.com/eric-holtzclaw/Nginx
- **Purpose:** Nginx deployment for gmaxgolfapp
- **CI/CD:** ✅ Yes (deploy config updates)
- **Why:** Reverse proxy for iOS app
- **Action:** Import from GitHub (mirror enabled)

---

### Group: **Forensics** 🔍

#### 5. **O365-Forensics-Investigator**
- **GitHub:** https://github.com/eric-holtzclaw/O365-Forensics-Investigator
- **Purpose:** Office 365 security investigation toolkit
- **CI/CD:** ⚠️ Optional (PowerShell scripts)
- **Why:** Track forensics tool development
- **Pipeline:** Test PowerShell modules, build reports

#### 6. **Google-Workspace-Forensics-Investigator**
- **GitHub:** https://github.com/eric-holtzclaw/Google-Workspace-Forensics-Investigator
- **Purpose:** Google Workspace security investigation toolkit
- **CI/CD:** ⚠️ Optional (Python scripts)
- **Why:** Track forensics tool development
- **Pipeline:** Test Python modules, validate configurations

#### 7. **workspace-token-monitor**
- **GitHub:** Not created yet (create in GitLab first)
- **Purpose:** Google Workspace token monitoring
- **CI/CD:** ⚠️ Optional
- **Action:** Create new project in GitLab

---

### Group: **Applications** 📱

#### 8. **gmaxgolfapp** ⭐ (HIGH PRIORITY)
- **GitHub:** https://github.com/eric-holtzclaw/gmaxgolfapp
- **Purpose:** iOS golf application (coming soon)
- **CI/CD:** ✅ Yes (critical for iOS builds)
- **Why:** Main application, needs CI/CD for builds
- **Pipeline:** 
  - Build iOS app
  - Run tests
  - Deploy to TestFlight/App Store
  - Update backend integration

#### 9. **muse**
- **GitHub:** Not created yet (create in GitLab first)
- **Purpose:** Muse EEG data collection system
- **CI/CD:** ⚠️ Optional (Home Assistant integration)
- **Why:** Track sleep tracking system
- **Action:** Create new project in GitLab

#### 10. **home-assistant** (or **HA**)
- **GitHub:** Not created yet (create in GitLab first)
- **Purpose:** Home Assistant configurations and automations
- **CI/CD:** ⚠️ Optional (config validation)
- **Why:** Track home automation configs
- **Action:** Create new project in GitLab

---

### Group: **Automation** 🤖

#### 11. **N8N**
- **GitHub:** https://github.com/eric-holtzclaw/N8N
- **Purpose:** N8N workflow automation deployment
- **CI/CD:** ⚠️ Optional (deployment automation)
- **Why:** Track N8N infrastructure
- **Note:** N8N workflows are managed in N8N UI, not Git

#### 12. **n8n-workflows**
- **GitHub:** Not created yet (create in GitLab first)
- **Purpose:** Export N8N workflows as code
- **CI/CD:** ⚠️ Optional
- **Why:** Version control for N8N workflows
- **Action:** Create new project, export workflows from N8N

---

### Group: **Development** 🛠️

#### 13. **kali**
- **GitHub:** https://github.com/eric-holtzclaw/kali
- **Purpose:** Kali Linux container deployment
- **CI/CD:** ⚠️ Optional (container updates)
- **Why:** Track security testing environment

#### 14. **dmarc**
- **GitHub:** Not created yet (create in GitLab first)
- **Purpose:** DMARC email security checker
- **CI/CD:** ⚠️ Optional
- **Action:** Create new project in GitLab

---

### Group: **Personal** 👤

#### 15. **whoop**
- **GitHub:** Not created yet (create in GitLab first)
- **Purpose:** Whoop fitness data integration
- **CI/CD:** ❌ No
- **Action:** Create new project in GitLab

#### 16. **health-app**
- **GitHub:** Not created yet (create in GitLab first)
- **Purpose:** Health app integrations
- **CI/CD:** ❌ No
- **Action:** Create new project in GitLab

---

## 🚀 Priority Order for Project Creation

### **Immediate (Today)**
1. ✅ **core** - Import from GitHub (critical infrastructure)
2. ✅ **gmaxgolfapp** - Import from GitHub (main app)
3. ✅ **supabase** - Import from GitHub (app backend)

### **This Week**
4. **nginx** - Create new (gmaxgolfapp infrastructure)
5. **O365-Forensics-Investigator** - Import from GitHub
6. **Google-Workspace-Forensics-Investigator** - Import from GitHub
7. **N8N** - Import from GitHub

### **This Month**
8. **kali** - Import from GitHub
9. **gitlab** - Import from GitHub (self-tracking)
10. **muse** - Create new
11. **home-assistant** - Create new
12. **workspace-token-monitor** - Create new

### **When Needed**
13. **dmarc** - Create new
14. **whoop** - Create new
15. **health-app** - Create new
16. **n8n-workflows** - Create new (if exporting workflows)

---

## 📝 Project Import Instructions

### For Existing GitHub Repositories

1. **In GitLab:**
   - Click **"New Project"**
   - Choose **"Import project"**
   - Select **"Repository by URL"**
   - Enter GitHub URL: `https://github.com/eric-holtzclaw/REPO_NAME.git`
   - Click **"Create project"**

2. **Configure CI/CD:**
   - Add `.gitlab-ci.yml` to repository
   - Configure CI/CD variables in GitLab UI
   - Test pipeline

### For New Projects

1. **In GitLab:**
   - Click **"New Project"**
   - Choose **"Create blank project"**
   - Name: `repo-name`
   - Visibility: Private (recommended)
   - Click **"Create project"**

2. **Push Local Code:**
   ```bash
   cd /path/to/local/project
   git init
   git remote add origin git@localhost:2222:username/repo-name.git
   git add .
   git commit -m "Initial commit"
   git push -u origin main
   ```

---

## 🔧 CI/CD Configuration Priority

### High Priority (Needs CI/CD)
1. **core** - Deployment automation
2. **gmaxgolfapp** - iOS app builds
3. **supabase** - Database deployments

### Medium Priority (Optional CI/CD)
4. **nginx** - Config deployment
5. **O365-Forensics-Investigator** - PowerShell module testing
6. **Google-Workspace-Forensics-Investigator** - Python testing

### Low Priority (No CI/CD Needed)
7. **N8N** - Infrastructure only
8. **kali** - Infrastructure only
9. **muse** - Home Assistant integration
10. **Personal projects** - Just version control

---

## 📊 Project Status Tracking

Create a tracking table in GitLab Wiki or README:

| Project | Group | Status | CI/CD | GitHub | GitLab |
|---------|-------|--------|-------|--------|--------|
| core | Infrastructure | ✅ Ready | ✅ Yes | ✅ | ⚠️ Need import |
| gmaxgolfapp | Applications | 🚧 Coming Soon | ✅ Yes | ✅ | ⚠️ Need import |
| supabase | Infrastructure | ✅ Ready | ✅ Yes | ✅ | ⚠️ Need import |
| nginx | Infrastructure | ✅ Deployed | ✅ Yes | ✅ | ⚠️ Need import |
| O365-Forensics | Forensics | ✅ Ready | ⚠️ Optional | ✅ | ⚠️ Need import |
| Google-Workspace-Forensics | Forensics | ⚠️ In Progress | ⚠️ Optional | ✅ | ⚠️ Need import |
| N8N | Automation | ✅ Deployed | ⚠️ Optional | ✅ | ⚠️ Need import |
| kali | Development | ✅ Deployed | ⚠️ Optional | ✅ | ⚠️ Need import |
| muse | Applications | ✅ Operational | ❌ No | ❌ | ✅ Create new |
| home-assistant | Applications | ✅ Operational | ⚠️ Optional | ❌ | ✅ Create new |

---

## 🎯 Quick Start: Create First 3 Projects

### Step 1: Create GitLab Groups

1. In GitLab, go to **Groups** → **New Group**
2. Create groups:
   - `Infrastructure`
   - `Forensics`
   - `Applications`
   - `Automation`
   - `Development`

### Step 2: Import Core Repository

1. Go to **Infrastructure** group
2. Click **"New Project"** → **"Import project"**
3. Select **"Repository by URL"**
4. Enter: `https://github.com/eric-holtzclaw/core.git`
5. Project name: `core`
6. Click **"Create project"**

### Step 3: Add CI/CD Pipeline

1. Go to **core** project → **Repository**
2. Create `.gitlab-ci.yml`:
   ```bash
   # Copy from GitLab/.gitlab-ci.yml.example
   cp /Users/eric/Documents/Scripts/infrastructure/gitlab/.gitlab-ci.yml.example .gitlab-ci.yml
   ```
3. Commit and push
4. Configure CI/CD variables in GitLab UI

### Step 4: Import gmaxgolfapp

1. Go to **Applications** group
2. Import: `https://github.com/eric-holtzclaw/gmaxgolfapp.git`
3. Configure iOS build pipeline (when ready)

### Step 5: Import Supabase

1. Go to **Infrastructure** group
2. Import: `https://github.com/eric-holtzclaw/supabase.git`
3. Configure database deployment pipeline

---

## 📋 Project Template Checklist

For each project, ensure:

- [ ] Project created in correct group
- [ ] Repository imported or initialized
- [ ] README.md updated
- [ ] `.gitlab-ci.yml` added (if CI/CD needed)
- [ ] CI/CD variables configured
- [ ] Protected branches configured (main branch)
- [ ] Project description filled out
- [ ] Tags added (e.g., `kubernetes`, `python`, `ios`, `forensics`)

---

## 🔗 Repository Mapping

| Local Directory | GitHub Repo | GitLab Project | Group | Priority |
|----------------|-------------|----------------|-------|----------|
| `core/` | ✅ core | ⚠️ Import | Infrastructure | 🔴 High |
| `browser/k8s-devops/` | ✅ core | ⚠️ Import | Infrastructure | 🔴 High |
| `N8N/` | ✅ N8N | ⚠️ Import | Automation | 🟡 Medium |
| `kali/` | ✅ kali | ⚠️ Import | Development | 🟡 Medium |
| `supabase/` | ✅ supabase | ⚠️ Import | Infrastructure | 🔴 High |
| `GitLab/` | ✅ gitlab | ⚠️ Import | Infrastructure | 🟡 Medium |
| `Nginx/` | ✅ Nginx | ⚠️ Import | Infrastructure | 🔴 High |
| `O365-Forensics-Investigator/` | ✅ O365-Forensics | ⚠️ Import | Forensics | 🟡 Medium |
| `Google-Workspace-Forensics-Investigator/` | ✅ Google-Workspace-Forensics | ⚠️ Import | Forensics | 🟡 Medium |
| `muse/` | ❌ None | ✅ Create New | Applications | 🟢 Low |
| `HA/` | ❌ None | ✅ Create New | Applications | 🟢 Low |
| `workspace-token-monitor/` | ❌ None | ✅ Create New | Forensics | 🟢 Low |
| `dmarc/` | ❌ None | ✅ Create New | Development | 🟢 Low |
| `whoop/` | ❌ None | ✅ Create New | Personal | 🟢 Low |
| `health_app/` | ❌ None | ✅ Create New | Personal | 🟢 Low |

**Legend:**
- ✅ = Exists
- ❌ = Doesn't exist (create new)
- ⚠️ = Needs action
- 🔴 = High priority
- 🟡 = Medium priority
- 🟢 = Low priority

---

## 🎯 Recommended First Actions

### Today (30 minutes)
1. Create GitLab groups
2. Import **core** repository
3. Import **gmaxgolfapp** repository
4. Import **supabase** repository

### This Week (2-3 hours)
1. Create **nginx** project
2. Import **N8N** repository
3. Import **kali** repository
4. Import **O365-Forensics-Investigator**
5. Import **Google-Workspace-Forensics-Investigator**

### This Month (as needed)
1. Create remaining projects when you need version control
2. Add CI/CD pipelines as needed
3. Export N8N workflows to `n8n-workflows` project

---

## 📚 Documentation

Each project should have:
- ✅ README.md with project overview
- ✅ CHANGELOG.md (track changes)
- ✅ .gitlab-ci.yml (if CI/CD needed)
- ✅ Documentation in `docs/` folder

---

**Last Updated:** November 2025  
**Status:** ✅ Ready to create projects in GitLab


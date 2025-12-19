# GitLab Migration Checklist

**Date Started:** _______________  
**Completed:** _______________

---

## Phase 1: Import Critical Repos (30 minutes)

### Prerequisites
- [ ] GitLab is running and accessible at http://localhost:8080
- [ ] Port-forward is active: `kubectl port-forward -n gitlab service/gitlab-service 8080:80`
- [ ] Logged into GitLab as root

### Create Groups
- [ ] Created `Infrastructure` group
- [ ] Created `Forensics` group
- [ ] Created `Applications` group
- [ ] Created `Automation` group
- [ ] Created `Development` group

### Import Repositories
- [ ] **core** - Imported to Infrastructure group
  - URL: https://github.com/eric-holtzclaw/core.git
  - Status: _______________
  - Notes: _______________

- [ ] **gmaxgolfapp** - Imported to Applications group
  - URL: https://github.com/eric-holtzclaw/gmaxgolfapp.git
  - Status: _______________
  - Notes: _______________

- [ ] **supabase** - Imported to Infrastructure group
  - URL: https://github.com/eric-holtzclaw/supabase.git
  - Status: _______________
  - Notes: _______________

- [ ] **nginx** - Imported to Infrastructure group
  - URL: https://github.com/eric-holtzclaw/Nginx.git
  - Status: _______________
  - Notes: _______________

---

## Phase 2: Set Up Mirroring (45 minutes)

### Prerequisites
- [ ] GitHub personal access token created
  - Token name: _______________
  - Scopes: `repo`, `workflow`
  - Token: [Stored securely]

### Configure Mirroring
- [ ] **core** - Push mirror configured
  - GitHub URL: https://github.com/eric-holtzclaw/core.git
  - Status: _______________
  - Test: Made test commit, verified in GitHub

- [ ] **gmaxgolfapp** - Push mirror configured
  - GitHub URL: https://github.com/eric-holtzclaw/gmaxgolfapp.git
  - Status: _______________
  - Test: Made test commit, verified in GitHub

- [ ] **supabase** - Push mirror configured
  - GitHub URL: https://github.com/eric-holtzclaw/supabase.git
  - Status: _______________
  - Test: Made test commit, verified in GitHub

- [ ] **nginx** - Push mirror configured
  - GitHub URL: https://github.com/eric-holtzclaw/Nginx.git
  - Status: _______________
  - Test: Made test commit, verified in GitHub

---

## Phase 3: Import Remaining Repos (1 hour)

### Forensics Repos
- [ ] **O365-Forensics-Investigator** - Imported to Forensics group
  - URL: https://github.com/eric-holtzclaw/O365-Forensics-Investigator.git
  - Status: _______________
  - Notes: _______________

- [ ] **Google-Workspace-Forensics-Investigator** - Imported to Forensics group
  - URL: https://github.com/eric-holtzclaw/Google-Workspace-Forensics-Investigator.git
  - Status: _______________
  - Notes: _______________

### Automation Repos
- [ ] **N8N** - Imported to Automation group
  - URL: https://github.com/eric-holtzclaw/N8N.git
  - Status: _______________
  - Notes: _______________

### Development Repos
- [ ] **kali** - Imported to Development group
  - URL: https://github.com/eric-holtzclaw/kali.git
  - Status: _______________
  - Notes: _______________

### Infrastructure Repos
- [ ] **gitlab** - Imported to Infrastructure group
  - URL: https://github.com/eric-holtzclaw/gitlab.git
  - Status: _______________
  - Notes: _______________

---

## Post-Migration Configuration

### Update Local Git Remotes
- [ ] Updated `core` remote to GitLab
- [ ] Updated `gmaxgolfapp` remote to GitLab
- [ ] Updated `supabase` remote to GitLab
- [ ] Updated `nginx` remote to GitLab
- [ ] Tested push to GitLab for each repo

### CI/CD Configuration
- [ ] Added `.gitlab-ci.yml` to `core`
- [ ] Added `.gitlab-ci.yml` to `gmaxgolfapp`
- [ ] Added `.gitlab-ci.yml` to `supabase`
- [ ] Added `.gitlab-ci.yml` to `nginx`

### CI/CD Variables (for each project)
- [ ] `K8S_SSH_KEY` configured
- [ ] `K8S_CONFIG` configured (base64)
- [ ] `DOCKERHUB_USER` configured
- [ ] `DOCKERHUB_PASSWORD` configured
- [ ] `GITHUB_TOKEN` configured (for mirroring)

### Testing
- [ ] Tested push to GitLab → GitHub mirroring
- [ ] Tested CI/CD pipeline execution
- [ ] Verified commits appear in both GitLab and GitHub
- [ ] Tested local git workflow

---

## Migration Summary

**Total Repositories:** 9
- **Mirrored:** 4 (core, gmaxgolfapp, supabase, nginx)
- **Imported Only:** 5 (forensics, N8N, kali, gitlab)

**Total Time:** ~2-3 hours

**Status:** ⚠️ In Progress / ✅ Complete

**Notes:**
_______________
_______________
_______________

---

**Last Updated:** _______________




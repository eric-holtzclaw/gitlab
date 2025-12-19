# GitLab Repository Changelog

**Purpose:** Track all changes to GitLab repository to ensure documentation stays in sync with actual implementation.

**CFORD Compliance:** This changelog ensures we maintain a single source of truth for changes and helps prevent documentation drift.

---

## Change Tracking Process

### When Making Changes:
1. **Make the change** (script, config, deployment, etc.)
2. **Update this CHANGELOG.md** with the change
3. **Update relevant documentation** if the change affects how things work
4. **Commit both together** (change + documentation update)

### Change Entry Format:
```
## [YYYY-MM-DD] - Change Description

**Type:** [Config|Script|Documentation|Deployment|Fix]
**Affected Files:**
- file1.sh
- file2.md

**Change Details:**
- What changed
- Why it changed
- Impact on usage

**Documentation Updated:**
- README.md (section updated)
- SSH_ACCESS_GUIDE.md (URLs corrected)
```

---

## [2025-11-04] - Fixed GitLab URL Configuration

**Type:** Documentation|Config
**Affected Files:**
- k8s/configmap.yaml (external_url configured as 'http://gitlab.local')
- README.md (URLs need update)
- SSH_ACCESS_GUIDE.md (URLs need update)
- All documentation referencing localhost:8080 for git remotes

**Change Details:**
- GitLab is configured with `external_url 'http://gitlab.local'` in configmap.yaml
- Git remotes should use `http://gitlab.local/group/repo.git` (not localhost:8080)
- Browser access still uses `http://localhost:8080` (via port-forward)
- Requires `/etc/hosts` entry: `127.0.0.1 gitlab.local`

**Documentation Updated:**
- README.md (Service URLs section)
- SSH_ACCESS_GUIDE.md (SSH URL format)
- CHANGELOG.md (this file - change tracking system)
- CFORD_COMPLIANCE.md (change tracking process)

**Impact:**
- All git remotes need to use `gitlab.local` domain
- Users must add gitlab.local to /etc/hosts
- Documentation now reflects actual setup

---

## [2025-11-04] - Added New User Setup Guide

**Type:** Documentation|Feature
**Affected Files:**
- SETUP_GUIDE.md (new file - comprehensive setup guide)

**Change Details:**
- Created complete setup guide for new users on Mac, Linux, and Windows
- Documents `/etc/hosts` configuration (persistent across reboots)
- Platform-specific instructions for hosts file modification
- Port-forward setup instructions
- SSH key setup (optional)
- Troubleshooting section
- Clarifies that hosts file entry is persistent (survives reboots)

**Documentation Updated:**
- SETUP_GUIDE.md (new comprehensive guide)
- README.md (added link to SETUP_GUIDE.md)
- CHANGELOG.md (this entry)

**Impact:**
- New users can easily set up GitLab access
- Clear instructions for all platforms (Mac, Linux, Windows)
- Reduces setup time and confusion

---

## Change Categories

- **Config:** Configuration file changes
- **Script:** Script modifications or additions
- **Documentation:** Documentation updates
- **Deployment:** Deployment process changes
- **Fix:** Bug fixes or corrections
- **Feature:** New features added

---

**Last Updated:** 2025-11-04


## [2025-11-04] - Push data-flow.drawio to GitLab

**Type:** Deployment|Feature|Script
**Affected Files:**
- Google-Workspace-Forensics-Investigator/data-flow.drawio
- Google-Workspace-Forensics-Investigator/README.md
- scripts/push-google-workspace-diagram.sh (new script)

**Change Details:**
- Created data-flow.drawio diagram for Google Workspace Forensics Investigator
- Updated README.md to embed diagram link
- Files committed locally and ready to push
- Created automated push script that tries multiple repository paths
- Script handles SSH and HTTP authentication
- Script automatically starts port-forwards if needed

**Documentation Updated:**
- CHANGELOG.md (this entry)
- push-google-workspace-diagram.sh (script with documentation)

**Usage:**
```bash
cd /Users/eric/Documents/Scripts/infrastructure/gitlab
./scripts/push-google-workspace-diagram.sh
```

**Status:** Script ready. Files committed locally. Run script once repository exists in GitLab.

**Correction:** Repository path corrected to `development/google-workspace-forensics-investigator` (all lowercase) based on actual GitLab UI.

**Status:** Push blocked - repository exists in UI but git can't access it. Created `FIX_REPOSITORY_ACCESS.md` with research-based solutions. Need exact clone URL from GitLab UI to determine correct git path.

**Resolution:** Push succeeded using HTTP to `open-source-development/google-workspace-forensics-investigator`. Scripts updated to use SSH first (best practice), with HTTP fallback.

---

## [2025-11-05] - GitLab Access Best Practices Documentation

**Type:** Documentation|Best Practices
**Affected Files:**
- BEST_PRACTICES_GITLAB_ACCESS.md (new file - comprehensive best practices)
- README.md (updated with best practice recommendations)

**Change Details:**
- Documented best practices for GitLab access in Kubernetes with port-forward
- Recommended SSH for git operations (no credentials, more secure)
- Clarified localhost:8080 vs gitlab.local usage
- Explained configuration alignment (external_url vs actual access)
- Provided recommendations for development vs production setups

**Best Practices:**
- ✅ Use SSH for git operations: `ssh://git@localhost:2222/group/repo.git`
- ✅ Use localhost:8080 for HTTP (not gitlab.local:80)
- ✅ Use Personal Access Tokens for automation (not passwords)
- ✅ Port-forward is temporary - restart after reboot

**Documentation Updated:**
- BEST_PRACTICES_GITLAB_ACCESS.md (new comprehensive guide)
- README.md (Git Remote URLs section updated)
- CHANGELOG.md (this entry)

**Impact:**
- Clear guidance on access methods
- Reduces confusion about gitlab.local vs localhost
- Establishes standard practices for development and production

---

## [2025-11-05] - Repository Path Fixes and Diagram Push Complete

**Type:** Fix|Documentation|Scripts
**Affected Files:**
- scripts/run-import.sh (updated to use SSH first, correct path)
- scripts/push-google-workspace-diagram.sh (verified path, SSH first)
- README.md (corrected example URLs)
- CHANGELOG.md (this entry)

**Change Details:**
- Verified correct repository path: `open-source-development/google-workspace-forensics-investigator`
- Successfully pushed `data-flow.drawio` and updated `README.md` to GitLab
- Updated all scripts to use SSH first (best practice), with HTTP fallback
- Fixed example URLs in documentation to use correct path

**Repository Path:**
- ✅ Correct: `open-source-development/google-workspace-forensics-investigator`
- ❌ Incorrect: `development/google-workspace-forensics-investigator`
- ❌ Incorrect: `microsoft-development/google-workspace-forensics-investigator`

**Files Pushed:**
- ✅ `data-flow.drawio` (5,532 bytes)
- ✅ `README.md` (with embedded diagram link)

**View Repository:**
- http://localhost:8080/open-source-development/google-workspace-forensics-investigator

**Impact:**
- Diagram now visible in GitLab repository
- All scripts use best practice (SSH first)
- Documentation reflects correct paths

---

## [2025-11-05] - Fixed GitLab URL Configuration (Root Cause Fix)

**Type:** Fix|Configuration
**Affected Files:**
- k8s/configmap.yaml (external_url changed from gitlab.local to localhost:8080)
- FIX_GITLAB_URLS.md (new troubleshooting guide)
- WHAT_WENT_WRONG.md (new explanation document)

**Change Details:**
- **Root cause identified:** `external_url 'http://gitlab.local'` didn't match actual access method (`localhost:8080`)
- **Fix applied:** Updated `external_url` to `http://localhost:8080`
- **Applied:** ConfigMap updated and GitLab restarted

**Why This Was Needed:**
- GitLab generated URLs using `gitlab.local` which didn't work
- Clicking links in GitLab redirected to broken URLs
- Documentation and clone URLs were confusing
- Multiple authentication attempts failed due to URL/path confusion

**The Fix:**
```yaml
# Before (broken)
external_url 'http://gitlab.local'

# After (works)
external_url 'http://localhost:8080'
```

**Impact:**
- All URLs in GitLab will now use `localhost:8080`
- Clicking links will work correctly
- Clone URLs will be correct
- Documentation aligns with reality
- Single source of truth established

**Lesson Learned:**
- Match configuration to actual access method
- Fix root cause, not symptoms
- Keep it simple - one URL format that works

**Status:** GitLab restarting, will be fixed after restart completes (5-10 minutes)

---

## [2025-11-05] - GitLab Permission Issues Fixed - FINAL SOLUTION

**Type:** Fix|Critical|Configuration
**Affected Files:**
- k8s/deployment.yaml (init container permissions fixed)
- scripts/monitor-gitlab.sh (enhanced to take corrective actions)
- CHANGELOG.md (this entry)

**Problem:**
GitLab pod was crashing repeatedly with permission errors:
- `FATAL: could not open file "/var/opt/gitlab/postgresql/data/PG_VERSION": Permission denied`
- `Fatal error: can't open the RDB file dump.rdb for reading: Permission denied`
- Pod restarted 8+ times

**Root Cause:**
Init container was using **wrong UIDs** for GitLab services:
- Used: PostgreSQL 999:999 (gitlab-www) ❌
- Should be: PostgreSQL 996:996 (gitlab-psql) ✅
- Used: Redis 998:998 ❌
- Should be: Redis 997:997 (gitlab-redis) ✅
- Used: GitLab Rails 1000:1000 ❌
- Should be: GitLab Rails 998:998 (git) ✅

**Additional Issues:**
1. `chown -R 1000:1000 /var/opt/gitlab` was overwriting PostgreSQL/Redis permissions
2. Init container was failing silently (errors hidden)
3. Cron job was only logging, not taking corrective actions

**Solution Applied:**

### 1. Fixed UIDs in Init Container
```yaml
# Correct UIDs for GitLab services:
chown -R 996:996 /var/opt/gitlab/postgresql  # gitlab-psql
chown -R 997:997 /var/opt/gitlab/redis       # gitlab-redis
chown -R 998:998 /var/opt/gitlab             # git (GitLab Rails)

# Set permissions AFTER general chown to prevent overwriting
chown -R 996:996 /var/opt/gitlab/postgresql
chown -R 997:997 /var/opt/gitlab/redis
```

### 2. Fixed Permission Order
- Set PostgreSQL/Redis permissions AFTER general chown
- Prevents general chown from overwriting service-specific permissions

### 3. Enhanced Monitoring Script
- Now actually restarts port-forward (with nohup)
- Detects permission errors and auto-restarts pod
- Takes corrective actions instead of just logging

### 4. Fixed Init Container Verbosity
- Added verbose output to see what's happening
- Fixed find command syntax (using `xargs` instead of `-exec \;`)

**Files Changed:**
- `k8s/deployment.yaml`: Init container command updated with correct UIDs
- `scripts/monitor-gitlab.sh`: Enhanced to take corrective actions

**GitLab Service UIDs (Reference):**
```
gitlab-psql:   996:996  (PostgreSQL)
gitlab-redis:  997:997  (Redis)
git:           998:998  (GitLab Rails)
gitlab-www:    999:999  (Nginx)
```

**Result:**
- ✅ GitLab pod: `1/1 Ready` (Running)
- ✅ HTTP: Healthy (redirects to sign-in)
- ✅ No permission errors
- ✅ Accessible at: http://localhost:8080

**Status:** ✅ **FIXED - GitLab is now UP and running**

**Time to Resolution:** ~2 hours (multiple permission fixes)
**Final Fix:** Correct UIDs (996 for PostgreSQL, 997 for Redis, 998 for GitLab Rails)

---

## [2025-11-05] - Production-Ready Setup Documentation Added

**Type:** Documentation|Enhancement
**Affected Files:**
- PRODUCTION_READY_SETUP.md (new comprehensive documentation)
- README.md (added production-ready section)
- CHANGELOG.md (this entry)

**Summary:**
Documented complete production-ready setup for GitLab access, including:
- LaunchAgent auto-start on Mac restart
- All access methods (SSH keys, root password, tokens)
- End-to-end testing and validation

**Details:**

### Production-Ready Features Documented:

1. **Automatic Port Forwarding on Restart** ✅
   - LaunchAgent: `~/Library/LaunchAgents/com.gitlab.portforward.plist` (loaded and active)
   - Management script: `scripts/manage-port-forward.sh`
   - Auto-starts on Mac login/restart
   - Monitoring: Checks every 5 minutes, restarts if needed

2. **All Access Methods Configured** ✅
   - SSH Keys: Primary (`id_ed25519.pub`), deploy key, HA key
   - Root Password: URL-encoded, working for all git operations
   - Token Access: Personal Access Token configured
   - **HTTP is recommended** (SSH port 2222 has known issues)

3. **End-to-End Testing** ✅
   - Test script: `scripts/test-end-to-end.sh`
   - All tests passing (port forwarding, HTTP access, git operations)

**Files Created:**
- `PRODUCTION_READY_SETUP.md` - Complete production-ready documentation

**Files Updated:**
- `README.md` - Added production-ready section with quick summary

**Status:** ✅ **Documentation complete**

**Repository:** http://localhost:8080/infrastructure/gitlab


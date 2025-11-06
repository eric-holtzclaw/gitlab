# GitLab Permission Fix - Complete Documentation

**Date:** November 5, 2025  
**Status:** ✅ **FIXED - GitLab is UP and running**

---

## Problem Summary

GitLab pod was crashing repeatedly with permission errors:
- `FATAL: could not open file "/var/opt/gitlab/postgresql/data/PG_VERSION": Permission denied`
- `Fatal error: can't open the RDB file dump.rdb for reading: Permission denied`
- Pod restarted 8+ times before fix

---

## Root Cause

**Wrong UIDs in Init Container**

The init container was using incorrect user IDs for GitLab services:

| Service | Wrong UID Used | Correct UID | User |
|---------|---------------|-------------|------|
| PostgreSQL | 999:999 ❌ | **996:996** ✅ | gitlab-psql |
| Redis | 998:998 ❌ | **997:997** ✅ | gitlab-redis |
| GitLab Rails | 1000:1000 ❌ | **998:998** ✅ | git |

**Additional Issues:**
1. `chown -R 1000:1000 /var/opt/gitlab` was overwriting PostgreSQL/Redis permissions
2. Init container commands were failing silently
3. Cron job was only logging, not taking corrective actions

---

## Solution

### 1. Correct UIDs in Init Container

**File:** `k8s/deployment.yaml`

**Final Working Command:**
```bash
chown -R 997:997 /var/opt/gitlab/redis        # gitlab-redis
chown -R 996:996 /var/opt/gitlab/postgresql  # gitlab-psql
chmod -R 755 /var/opt/gitlab/redis
chmod -R 700 /var/opt/gitlab/postgresql/data
chmod -R 600 /var/opt/gitlab/postgresql/data/* (files)
chown -R 998:998 /var/opt/gitlab             # git (general)
# Re-apply service-specific permissions AFTER general chown
chown -R 996:996 /var/opt/gitlab/postgresql  # Prevent overwrite
chown -R 997:997 /var/opt/gitlab/redis       # Prevent overwrite
```

### 2. Fixed Permission Order

**Critical:** Set service-specific permissions AFTER general chown to prevent overwriting.

**Before (broken):**
```bash
chown -R 999:999 /var/opt/gitlab/postgresql  # Set PostgreSQL
chown -R 1000:1000 /var/opt/gitlab            # Overwrites PostgreSQL! ❌
```

**After (fixed):**
```bash
chown -R 998:998 /var/opt/gitlab             # General first
chown -R 996:996 /var/opt/gitlab/postgresql  # PostgreSQL AFTER ✅
chown -R 997:997 /var/opt/gitlab/redis       # Redis AFTER ✅
```

### 3. Enhanced Monitoring Script

**File:** `scripts/monitor-gitlab.sh`

**Changes:**
- Removed `set -e` to allow error handling
- Added proper port-forward restart (with `nohup`)
- Added permission error detection and auto-restart
- Added corrective actions (not just logging)

### 4. Fixed Find Command Syntax

**Before:**
```bash
find ... -exec chmod 600 {} \;  # Failing silently
```

**After:**
```bash
find ... -print0 | xargs -0 chmod 600  # Working correctly
```

---

## GitLab Service UIDs Reference

**Verified from `/etc/passwd` in GitLab container:**

```
gitlab-psql:   996:996  (PostgreSQL)
gitlab-redis:  997:997  (Redis)
git:           998:998  (GitLab Rails)
gitlab-www:    999:999  (Nginx)
```

**Important:** These are GitLab-specific UIDs, not standard Linux UIDs.

---

## Complete Fix Command (Final Working Version)

```bash
echo "Starting permission fix..."
chown -R 997:997 /var/opt/gitlab/redis || echo "Redis chown failed"
chmod -R 755 /var/opt/gitlab/redis || true
chown -R 996:996 /var/opt/gitlab/postgresql || echo "PostgreSQL chown failed"
if [ -d /var/opt/gitlab/postgresql/data ]; then
    echo "Fixing PostgreSQL data directory (gitlab-psql:996:996)..."
    chown -R 996:996 /var/opt/gitlab/postgresql/data
    chmod -R 700 /var/opt/gitlab/postgresql/data
    find /var/opt/gitlab/postgresql/data -type f -print0 | xargs -0 chmod 600 || echo "File chmod failed"
    ls -la /var/opt/gitlab/postgresql/data/PG_VERSION || echo "PG_VERSION not found"
fi
chown -R 998:998 /var/opt/gitlab || true
# Re-apply service-specific permissions AFTER general chown
chown -R 996:996 /var/opt/gitlab/postgresql || true
chown -R 997:997 /var/opt/gitlab/redis || true
echo "Permissions fix complete"
```

---

## Files Changed

### 1. `k8s/deployment.yaml`
- **Line 26:** Init container command updated with correct UIDs
- **Change:** PostgreSQL 996:996, Redis 997:997, GitLab 998:998
- **Fix:** Permission order (service-specific AFTER general)

### 2. `scripts/monitor-gitlab.sh`
- **Line 6:** Removed `set -e` for error handling
- **Lines 79-83:** Added permission error detection and auto-restart
- **Lines 85-96:** Enhanced port-forward restart (with nohup)
- **Lines 104-122:** Added stuck pod detection

### 3. `k8s/configmap.yaml`
- **Line 10:** Changed `external_url` from `gitlab.local` to `localhost:8080`
- **Line 32:** Added Prometheus external_url
- **Line 33:** Removed Grafana config (not supported in CE)

### 4. `CHANGELOG.md`
- Added entries documenting all fixes

---

## Verification

**After fix applied:**
```bash
$ kubectl get pods -n gitlab
NAME                     READY   STATUS    RESTARTS   AGE
gitlab-7bc887d5df-gbg4b   1/1     Running   1          24m

$ curl -s http://localhost:8080
<html><body>You are being <a href="http://localhost:8080/users/sign_in">redirected</a>.</body></html>
```

**Status:** ✅ **GitLab is UP and healthy**

---

## Lessons Learned

1. **Verify actual UIDs:** Don't assume - check `/etc/passwd` in the container
2. **Permission order matters:** Set service-specific permissions AFTER general chown
3. **Init container debugging:** Use verbose output to see what's actually happening
4. **Test find commands:** `-exec \;` can fail silently, use `xargs` instead
5. **Monitor scripts should act:** Don't just log - take corrective actions

---

## Prevention

**For future deployments:**

1. **Always check service UIDs first:**
   ```bash
   kubectl exec -n gitlab <pod> -- cat /etc/passwd | grep -E "postgres|redis|git"
   ```

2. **Use correct permission order:**
   - General chown first
   - Service-specific chown AFTER (to prevent overwrite)

3. **Test init container:**
   ```bash
   kubectl logs <pod> -c volume-permissions
   ```

4. **Verify permissions after init:**
   ```bash
   kubectl exec <pod> -- ls -la /var/opt/gitlab/postgresql/data/PG_VERSION
   ```

---

## Timeline

- **15:00** - Initial permission errors detected
- **15:30** - First fix attempt (wrong UIDs)
- **16:00** - Discovered correct UIDs from `/etc/passwd`
- **16:15** - Fixed UIDs and permission order
- **16:30** - ✅ **GitLab UP and running**

**Total time:** ~1.5 hours
**Final fix:** Correct UIDs (996, 997, 998) in proper order

---

**Last Updated:** November 5, 2025  
**Status:** ✅ **COMPLETE - GitLab is UP and running**


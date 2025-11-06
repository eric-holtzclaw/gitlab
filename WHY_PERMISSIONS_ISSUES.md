# Why Permission Issues Occurred - Root Cause Analysis

**Date:** November 5, 2025  
**Issue:** Multiple permission errors preventing GitLab from starting

---

## The Root Cause

**Persistent Volumes + Multiple Services = Permission Chaos**

### What Happened

1. **Persistent Volume Created**
   - Kubernetes PersistentVolume created with default permissions
   - Files owned by whoever created them (likely `ubuntu` user or root)
   - Volume reused across pod restarts

2. **GitLab Omnibus Runs Multiple Services**
   - PostgreSQL: runs as UID `999` (postgres user)
   - Redis: runs as UID `998` (redis user)
   - GitLab Rails: runs as UID `1000` (git user)
   - Each service needs specific file ownership

3. **Permission Mismatch**
   - Volume files owned by wrong user (e.g., `ubuntu:ubuntu`)
   - Services can't access their own files
   - Results in: "Permission denied" errors

---

## How It Got Messed Up

### Timeline of Events

1. **Initial Setup**
   ```
   PersistentVolume created
   → Files created as root or ubuntu user
   → GitLab pod starts
   → Services try to access files
   → PERMISSION DENIED
   ```

2. **First Attempts to Fix**
   ```
   Added init container with chown 1000:1000
   → Fixed GitLab Rails permissions
   → But PostgreSQL (999) and Redis (998) still broken
   ```

3. **Cascade of Errors**
   ```
   Redis can't read dump.rdb → GitLab crashes
   PostgreSQL can't read pg_control → GitLab crashes
   Each restart → Same permission errors
   ```

---

## Why Each Service Needs Specific Permissions

### PostgreSQL (UID 999)
- **Needs:** `700` on directories, `600` on files
- **Why:** PostgreSQL is strict about file permissions for security
- **Files:** `global/pg_control`, data files, WAL files
- **Error:** `PANIC: could not open file "global/pg_control": Permission denied`

### Redis (UID 998)
- **Needs:** `755` on directories, `644` on files (or owned by redis user)
- **Why:** Redis needs to read/write its database files
- **Files:** `dump.rdb`, `redis.conf`
- **Error:** `Fatal error: can't open the RDB file dump.rdb for reading: Permission denied`

### GitLab Rails (UID 1000)
- **Needs:** `755` on directories, `644` on files
- **Why:** GitLab Rails needs to access repositories, uploads, etc.
- **Files:** Repositories, uploads, logs
- **Error:** Various permission errors depending on what it's accessing

---

## Why Init Container Wasn't Enough Initially

### Original Init Container
```bash
chown -R 1000:1000 /var/opt/gitlab
```
**Problem:**
- Only fixed GitLab Rails (UID 1000) permissions
- PostgreSQL (UID 999) still had wrong ownership
- Redis (UID 998) still had wrong ownership

### Fixed Init Container
```bash
# Fix each service's permissions
chown -R 998:998 /var/opt/gitlab/redis        # Redis
chown -R 999:999 /var/opt/gitlab/postgresql  # PostgreSQL
chown -R 1000:1000 /var/opt/gitlab           # GitLab Rails

# Fix PostgreSQL strict permissions
chmod -R 700 /var/opt/gitlab/postgresql       # Dirs: owner-only
chmod -R 600 /var/opt/gitlab/postgresql      # Files: owner-only
```

---

## Why This Happens in Kubernetes

### PersistentVolume Behavior

1. **Volume Created Once**
   - Files created with initial ownership
   - Ownership persists across pod restarts
   - Pods restart, but volume keeps old permissions

2. **No Automatic Permission Fix**
   - Kubernetes doesn't automatically fix permissions
   - You must use init containers to fix them
   - If init container doesn't fix everything, services fail

3. **Different Services, Different Users**
   - Each GitLab service runs as different user
   - All need access to same volume
   - Must fix permissions for ALL services

---

## The Solution

### Multi-Step Permission Fix

1. **Fix Ownership First**
   ```bash
   chown -R 998:998 /var/opt/gitlab/redis
   chown -R 999:999 /var/opt/gitlab/postgresql
   chown -R 1000:1000 /var/opt/gitlab
   ```

2. **Fix PostgreSQL Permissions (Strict)**
   ```bash
   chmod -R 700 /var/opt/gitlab/postgresql  # Dirs
   chmod -R 600 /var/opt/gitlab/postgresql  # Files
   ```

3. **Fix General Permissions**
   ```bash
   find /var/opt/gitlab -type d -exec chmod 755 {} \;
   find /var/opt/gitlab -type f -exec chmod 644 {} \;
   ```

---

## Prevention for Future

### Best Practices

1. **Fix Permissions on First Deploy**
   - Init container should fix ALL service permissions
   - Don't wait for errors to fix them

2. **Use fsGroup**
   ```yaml
   securityContext:
     fsGroup: 1000  # Helps with default ownership
   ```
   - But doesn't fix all services (PostgreSQL, Redis still need specific UIDs)

3. **Comprehensive Init Container**
   - Fix permissions for ALL services
   - Use correct UIDs (999, 998, 1000)
   - Use correct permissions (700/600 for PostgreSQL)

4. **Test Permissions**
   - Verify all services can access their files
   - Check logs for permission errors
   - Don't assume init container fixed everything

---

## Summary

**Why it happened:**
- Persistent volume created with wrong ownership
- Multiple services (PostgreSQL, Redis, GitLab) need different UIDs
- Init container only fixed one service's permissions
- Each restart → same permission errors

**The fix:**
- Init container now fixes permissions for ALL services
- Specific UIDs: 999 (PostgreSQL), 998 (Redis), 1000 (GitLab)
- PostgreSQL gets strict permissions (700/600)

**Prevention:**
- Always fix permissions for ALL services in init container
- Don't assume one chown fixes everything
- Test that services can actually access their files

---

**Last Updated:** November 5, 2025  
**Status:** Root cause identified and fixed


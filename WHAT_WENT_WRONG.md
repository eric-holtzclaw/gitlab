# What Went Wrong - Honest Explanation

**Date:** November 5, 2025  
**Context:** Why GitLab setup got complicated

---

## The Root Cause

**One simple mismatch caused everything:**

```
Configured:    gitlab.local (port 80)
Reality:       localhost:8080 (port-forward)
```

This one thing broke:
- URL generation
- Clone URLs
- Documentation
- SSH paths
- Authentication attempts

---

## The Cascade of Problems

### 1. Initial Setup (Made Sense at the Time)
- GitLab deployed in Kubernetes
- Used `external_url 'http://gitlab.local'` (standard practice)
- Added `/etc/hosts` entry for `gitlab.local`
- **But:** Only accessible via port-forward on `localhost:8080`

### 2. First Problem: URLs Don't Work
- GitLab generates URLs using `external_url`
- Generated: `http://gitlab.local/root`
- But access is: `http://localhost:8080`
- **Result:** Clicking links fails

### 3. Second Problem: Documentation Confusion
- Docs said "use gitlab.local"
- But gitlab.local:80 doesn't work (port-forward is on 8080)
- Created confusion about which URL to use

### 4. Third Problem: SSH Path Confusion
- GitLab shows clone URLs using `gitlab.local`
- But SSH only works with `localhost:2222`
- Multiple path attempts (development vs open-source-development)
- Root user permissions (Owner but still failing)

### 5. Fourth Problem: Authentication Chaos
- Token expired (401 errors)
- Root password has special characters (encoding issues)
- SSH key works but repository access denied
- Multiple authentication methods tried

### 6. Fifth Problem: Piecemeal Fixes
- Fixed one thing at a time
- Didn't address root cause
- Created more confusion
- Documentation got out of sync

---

## Why It Happened

### Reason 1: Standard Practice vs Reality
- GitLab docs suggest using a domain name (`gitlab.local`)
- But in Kubernetes with port-forward, `localhost:8080` is the reality
- **Mismatch:** Configuration didn't match access method

### Reason 2: Incremental Problem Solving
- Each problem seemed separate
- Fixed symptoms, not root cause
- Created more complexity

### Reason 3: Multiple Access Methods
- HTTP (port 8080)
- SSH (port 2222)
- Different paths, different formats
- No single source of truth

---

## The Simple Fix

**One change fixes everything:**

```yaml
external_url 'http://localhost:8080'  # Instead of 'http://gitlab.local'
```

**Why this works:**
- Matches actual access method
- All URLs generate correctly
- Documentation aligns
- No confusion

---

## What We Learned

1. **Match configuration to reality**
   - If access is `localhost:8080`, configure `external_url` to match
   - Don't try to make it work with a different domain

2. **Fix root cause, not symptoms**
   - Should have changed `external_url` immediately
   - Instead, tried to fix each symptom separately

3. **Single source of truth**
   - One URL format that works
   - All documentation uses same format
   - No alternatives or confusion

---

## Current Status

✅ **Fixed:**
- `external_url` updated to `localhost:8080`
- ConfigMap applied
- GitLab restarting

✅ **After restart:**
- All URLs will work
- Documentation aligned
- Single source of truth

---

## Going Forward

**Simple rule:**
- Access GitLab: `http://localhost:8080`
- Clone URLs: `http://localhost:8080/group/repo.git`
- SSH URLs: `ssh://git@localhost:2222/group/repo.git`
- Documentation: Always use `localhost:8080`

**No more confusion.**

---

## Summary

**What happened:**
- Configuration didn't match reality
- Generated URLs that didn't work
- Created confusion and complexity

**The fix:**
- One config change: `external_url 'http://localhost:8080'`
- Everything aligns now

**The lesson:**
- Match config to actual access method
- Fix root cause, not symptoms
- Keep it simple

---

**Last Updated:** November 5, 2025  
**Status:** Fixed - configuration now matches reality


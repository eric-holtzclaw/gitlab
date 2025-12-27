# GitLab 500 Error - Fix Required

**Date:** December 20, 2024  
**Error:** 500 Internal Server Error on CI/CD Settings page  
**Request IDs:** 01KCZ7274K5FD84RZ37XTZX7YM, 01KCZ7N1GZBJ6842WH5FMXMGPX, 01KCZ7PHSMVY2QJ486A70039F9  
**URL:** http://10.0.0.16:8080/open-source-development/kali/-/settings/ci_cd  
**Status:** ⚠️ **NEEDS FIX**

---

## Browser Test Results

**Tested via browser:** ✅ Confirmed 500 error  
**Error persists:** Yes  
**Multiple request IDs:** Different IDs indicate multiple attempts

---

## Fix Script Created

Created automated fix script: `fix-500-error.sh`

### To Apply Fix:

```bash
cd /Users/eric/Documents/Scripts/infrastructure/gitlab
chmod +x fix-500-error.sh
./fix-500-error.sh
```

### Manual Fix Steps:

```bash
# 1. Clear GitLab cache
kubectl exec -n gitlab deployment/gitlab -- gitlab-rake cache:clear

# 2. Restart GitLab pod
kubectl rollout restart deployment/gitlab -n gitlab

# 3. Wait for restart (2-3 minutes)
kubectl rollout status deployment/gitlab -n gitlab --timeout=300s

# 4. Check logs for the specific error
kubectl logs -n gitlab deployment/gitlab --tail=200 | \
  grep -i "01KCZ7\|error\|exception\|ci_cd\|settings" | tail -20
```

---

## Root Cause Analysis Needed

Since the error persists, we need to check:

1. **GitLab Logs:**
   ```bash
   kubectl logs -n gitlab deployment/gitlab --tail=500 | \
     grep -A 10 -B 10 "01KCZ7"
   ```

2. **Database Migrations:**
   ```bash
   kubectl exec -n gitlab deployment/gitlab -- \
     gitlab-rake db:migrate:status
   ```

3. **Project-Specific Issue:**
   - Check if other project CI/CD settings work
   - Check if kali project has corrupted data

4. **GitLab 18.7.0 Bug:**
   - May be a known issue in 18.7.0
   - Check GitLab issue tracker

---

## Next Steps

1. **Run the fix script** (or manual commands above)
2. **Check GitLab logs** for specific error details
3. **Test other projects** to see if issue is project-specific
4. **If persists:** May need to rollback to 18.6.2 or wait for 18.7.1

---

**Status:** Fix script ready, needs execution  
**Priority:** High (blocking CI/CD configuration)



# GitLab MCP Status Check

**Date:** December 20, 2024  
**Time:** Current Status Check

---

## Current Status: ⚠️ **PARTIALLY WORKING**

### Direct API Access: ✅ **WORKING**
- **Version Endpoint:** ✅ Returns GitLab 18.7.0
- **Projects List:** ✅ Returns project data successfully
- **Authentication:** ✅ Token is valid and working

### MCP Server Access: ⚠️ **500 ERROR**
- **MCP `list_projects`:** ❌ Returns 500 Internal Server Error
- **Error Message:** `MCP error -32603: GitLab API error: 500 Internal Server Error`

---

## Diagnosis

### What's Working
1. ✅ GitLab API is accessible at `http://10.0.0.16:8080/api/v4`
2. ✅ Authentication token is valid
3. ✅ Direct `curl` requests to API endpoints succeed
4. ✅ GitLab version endpoint returns: `18.7.0`

### What's Not Working
1. ❌ MCP server `list_projects` call returns 500 error
2. ⚠️ This may be an intermittent GitLab server issue
3. ⚠️ Could be related to the recent 500 error on CI/CD settings page

---

## Test Results

### Direct API Test (✅ PASSED)
```bash
curl -H "PRIVATE-TOKEN: $TOKEN" "http://10.0.0.16:8080/api/v4/version"
# Result: {"version":"18.7.0","revision":"ef8306c4594",...}

curl -H "PRIVATE-TOKEN: $TOKEN" "http://10.0.0.16:8080/api/v4/projects?per_page=1"
# Result: [{"id":22,"name":"web-server",...}]
```

### MCP Test (❌ FAILED)
```
mcp_gitlab-mcp-free_list_projects()
# Result: MCP error -32603: GitLab API error: 500 Internal Server Error
```

---

## Possible Causes

1. **Intermittent GitLab Server Issue**
   - GitLab may be experiencing temporary 500 errors
   - Could be related to the CI/CD settings 500 error we saw earlier
   - May resolve after cache clear/restart

2. **MCP Server Request Format**
   - MCP server may be sending requests in a format that triggers GitLab errors
   - Could be a pagination or parameter issue

3. **GitLab Internal State**
   - Database migration issues
   - Cache corruption
   - Background job failures

---

## Recommended Actions

### Immediate Steps
1. **Check GitLab Logs:**
   ```bash
   kubectl logs -n gitlab deployment/gitlab --tail=100 | grep -i "500\|error"
   ```

2. **Clear GitLab Cache:**
   ```bash
   kubectl exec -n gitlab deployment/gitlab -- gitlab-rake cache:clear
   ```

3. **Restart GitLab Pod:**
   ```bash
   kubectl rollout restart deployment/gitlab -n gitlab
   ```

### Testing After Fix
1. **Test Direct API:**
   ```bash
   curl -H "PRIVATE-TOKEN: $TOKEN" \
     "http://10.0.0.16:8080/api/v4/projects?per_page=5"
   ```

2. **Test MCP:**
   - Try `list_projects` again via MCP
   - Try `get_project` with a specific project ID
   - Check if error is consistent or intermittent

---

## Configuration Verified

- **MCP Server:** `@zereight/mcp-gitlab`
- **GitLab API URL:** `http://10.0.0.16:8080/api/v4`
- **Token:** Active (expires 2026-12-06)
- **GitLab Version:** 18.7.0

---

## Root Cause Identified ✅

**Error:** `OpenSSL::Cipher::CipherError` when decrypting `runners_token`

**Location:** `app/models/project.rb:2622:in 'runners_token'`

**Cause:** Cryptographic error when GitLab tries to decrypt encrypted runner tokens after the upgrade to 18.7.0. The encryption key or encrypted data may be corrupted or mismatched.

**Affected:** Project-specific API calls that return project details (which includes `runners_token`)

---

## Fix Applied

Created `fix-mcp-500-error.sh` script that:
1. Regenerates project runner tokens
2. Clears GitLab cache
3. Restarts GitLab pod
4. Verifies API access

**To run the fix:**
```bash
./fix-mcp-500-error.sh
```

**Alternative manual fix:**
```bash
# Regenerate all project runner tokens
kubectl exec -n gitlab deployment/gitlab -- \
  gitlab-rake gitlab:project:regenerate_all_runners_tokens

# Clear cache and restart
kubectl exec -n gitlab deployment/gitlab -- gitlab-rake cache:clear
kubectl rollout restart deployment/gitlab -n gitlab
```

---

## Next Steps

1. ✅ Root cause identified (crypto error)
2. ✅ Fix script created
3. ⏳ Run fix script
4. ⏳ Retest MCP after fix
5. ⏳ Document resolution

---

**Status:** 🔧 **FIX READY** - Root cause identified, fix script created


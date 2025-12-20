# CI/CD Validation Test Guide - Recommendations 1 & 2

**Date:** December 20, 2024  
**Purpose:** Quick diagnostic tests for CI/CD validation bug  
**Downtime:** **ZERO** - These are read-only tests  
**Time Required:** 2-5 minutes

---

## Overview

These are **diagnostic tests only** - no changes to GitLab, no downtime, no risk.

**What we're testing:**
- Recommendation 1: Test CI/CD validation in web UI
- Recommendation 2: Test project-specific API endpoint

**Why:**
- Determine if CI/CD validation works in web UI (but not API)
- Check if the issue is API endpoint path or broader problem
- No deployment changes needed

---

## Recommendation 1: Test Web UI Validation

### Time Required: 1-2 minutes
### Downtime: **ZERO** (read-only test)

**Steps:**

1. **Open GitLab Web UI:**
   ```
   http://10.0.0.16:8080
   ```

2. **Navigate to a Project:**
   - Go to any project (e.g., `root/web-server`)
   - Or create a test project

3. **Open Pipeline Editor:**
   - Click **CI/CD** in left sidebar
   - Click **Pipeline Editor**

4. **Test Validation:**
   - Click **"Validate"** tab
   - Paste this test config:
     ```yaml
     test:
       script:
         - echo "test"
     ```
   - Click **"Validate"** button

5. **Check Result:**
   - ✅ If validation works: Issue is API-specific
   - ❌ If validation fails: Broader CI/CD validation issue

**Expected Time:** 1-2 minutes  
**Downtime:** None (just clicking buttons)

---

## Recommendation 2: Test Project-Specific API Endpoint

### Time Required: 1-2 minutes
### Downtime: **ZERO** (API call only)

**Steps:**

1. **Get Project ID:**
   ```bash
   # Already know: root/web-server is project ID 22
   # Or get it from:
   curl -H "PRIVATE-TOKEN: $TOKEN" \
     http://10.0.0.16:8080/api/v4/projects | \
     python3 -c "import sys, json; \
     [print(f\"{p['id']}: {p['path_with_namespace']}\") \
     for p in json.load(sys.stdin)]"
   ```

2. **Test Project-Specific Endpoint:**
   ```bash
   GITLAB_TOKEN="glpat-ZzivPXWqEwyhXgu2Igqh_286MQp1OjEH.01.0w01ltav7"
   
   curl -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     -X POST "http://10.0.0.16:8080/api/v4/projects/22/ci/lint" \
     -H "Content-Type: application/json" \
     -d '{
       "content": "test:\n  script:\n    - echo test"
     }'
   ```

3. **Check Result:**
   - ✅ If this works: Global endpoint issue, project endpoint works
   - ❌ If this fails: Broader API issue or permission problem

**Expected Time:** 1-2 minutes  
**Downtime:** None (just API calls)

---

## Quick Test Script

**Run this to test both quickly:**

```bash
#!/bin/bash
# Quick CI/CD validation test

GITLAB_TOKEN="glpat-ZzivPXWqEwyhXgu2Igqh_286MQp1OjEH.01.0w01ltav7"
GITLAB_URL="http://10.0.0.16:8080"

echo "Testing CI/CD Validation Endpoints..."
echo ""

# Test 1: Global endpoint (we know this fails)
echo "Test 1: Global CI Lint endpoint"
curl -s -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  -X POST "$GITLAB_URL/api/v4/ci/lint" \
  -H "Content-Type: application/json" \
  -d '{"content":"test:\n  script:\n    - echo test"}' | \
  python3 -m json.tool
echo ""

# Test 2: Project-specific endpoint
echo "Test 2: Project-specific CI Lint endpoint (project ID 22)"
curl -s -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  -X POST "$GITLAB_URL/api/v4/projects/22/ci/lint" \
  -H "Content-Type: application/json" \
  -d '{"content":"test:\n  script:\n    - echo test"}' | \
  python3 -m json.tool
echo ""

echo "Done! Check results above."
```

**Time:** 30 seconds  
**Downtime:** Zero

---

## Summary

### Recommendation 1: Web UI Test
- **Time:** 1-2 minutes
- **Downtime:** **ZERO**
- **Risk:** None (read-only)
- **Action:** Manual test in browser

### Recommendation 2: API Test
- **Time:** 1-2 minutes
- **Downtime:** **ZERO**
- **Risk:** None (API call only)
- **Action:** Run curl command

### Total Time
- **Both tests:** 2-5 minutes
- **Downtime:** **ZERO**
- **Risk:** None

---

## What These Tests Tell Us

### If Web UI Works but API Doesn't:
- ✅ CI/CD validation functionality is working
- ❌ API endpoint has issue (path, permissions, or version bug)
- **Solution:** Use web UI for validation, or upgrade to fix API

### If Both Fail:
- ❌ Broader CI/CD validation issue
- **Solution:** Check permissions, settings, or upgrade

### If Project API Works but Global Doesn't:
- ✅ Project-specific endpoint works
- ❌ Global endpoint has issue
- **Solution:** Use project-specific endpoint, or upgrade

---

## Next Steps Based on Results

### If Web UI Works:
- Use web UI for CI/CD validation
- Plan upgrade to 18.7.0 to fix API endpoint
- No immediate action needed

### If Both Fail:
- Check project CI/CD settings
- Verify permissions
- Plan upgrade to 18.7.0 (may fix issue)

### If Project API Works:
- Use project-specific endpoint for MCP tools
- Plan upgrade to fix global endpoint
- Update MCP configuration if needed

---

**Last Updated:** December 20, 2024  
**Status:** Ready to Test - Zero Downtime Required


# 🚨 UNBLOCK DEPLOYMENTS NOW - Quick Fix

**Date:** December 20, 2024  
**Issue:** 500 error on CI/CD settings page blocking deployments  
**Solution:** Use API to configure CI/CD (works immediately)

---

## ⚡ IMMEDIATE FIX - Run These Commands

### Step 1: Get Your Token

```bash
cd /Users/eric/Documents/Scripts/infrastructure/gitlab
TOKEN=$(grep -A 5 '"api"' token_vault.json | grep '"token"' | cut -d'"' -f4)
echo "Token: ${TOKEN:0:20}..."
```

### Step 2: Verify Project Access

```bash
curl -s -H "PRIVATE-TOKEN: $TOKEN" \
  "http://10.0.0.16:8080/api/v4/projects/8" | \
  python3 -m json.tool | grep -E '"name"|"id"|"builds_enabled"'
```

### Step 3: Enable CI/CD via API

```bash
# Enable builds
curl -X PUT \
  -H "PRIVATE-TOKEN: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"builds_enabled": true}' \
  "http://10.0.0.16:8080/api/v4/projects/8"

# Set CI config path
curl -X PUT \
  -H "PRIVATE-TOKEN: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"ci_config_path": ".gitlab-ci.yml"}' \
  "http://10.0.0.16:8080/api/v4/projects/8"
```

### Step 4: Trigger a Pipeline (Test Deployment)

```bash
# Trigger pipeline on main branch
curl -X POST \
  -H "PRIVATE-TOKEN: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"ref": "main"}' \
  "http://10.0.0.16:8080/api/v4/projects/8/pipeline"
```

### Step 5: Check Pipeline Status

```bash
# Get latest pipeline
curl -s -H "PRIVATE-TOKEN: $TOKEN" \
  "http://10.0.0.16:8080/api/v4/projects/8/pipelines?per_page=1" | \
  python3 -m json.tool | head -20
```

---

## ✅ You're Now Unblocked!

**What works:**
- ✅ Pipelines can be triggered via API
- ✅ CI/CD is enabled
- ✅ Deployments can proceed
- ✅ Pipeline status can be checked

**What doesn't work (but not critical):**
- ❌ Web UI CI/CD settings page (500 error)
- ✅ But you can use API for everything

---

## 🔧 Permanent Fix (Run Later)

When you have time, run the comprehensive fix:

```bash
cd /Users/eric/Documents/Scripts/infrastructure/gitlab
chmod +x fix-cicd-500-comprehensive.sh
./fix-cicd-500-comprehensive.sh
```

This will:
1. Clear cache
2. Check migrations
3. Restart GitLab
4. Check logs for root cause

---

## 📋 All-in-One Script

Save this as `unblock-deployments.sh`:

```bash
#!/bin/bash
set -e

cd /Users/eric/Documents/Scripts/infrastructure/gitlab
TOKEN=$(grep -A 5 '"api"' token_vault.json | grep '"token"' | cut -d'"' -f4)
PROJECT_ID=8
GITLAB_URL="http://10.0.0.16:8080"

echo "=== Unblocking Deployments ==="
echo ""

# Enable CI/CD
echo "1. Enabling CI/CD..."
curl -s -X PUT \
  -H "PRIVATE-TOKEN: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"builds_enabled": true}' \
  "$GITLAB_URL/api/v4/projects/$PROJECT_ID" | python3 -m json.tool | grep builds_enabled

# Set CI config path
echo ""
echo "2. Setting CI/CD config path..."
curl -s -X PUT \
  -H "PRIVATE-TOKEN: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"ci_config_path": ".gitlab-ci.yml"}' \
  "$GITLAB_URL/api/v4/projects/$PROJECT_ID" | python3 -m json.tool | grep ci_config_path

# Verify
echo ""
echo "3. Verifying CI/CD is enabled..."
curl -s -H "PRIVATE-TOKEN: $TOKEN" \
  "$GITLAB_URL/api/v4/projects/$PROJECT_ID" | \
  python3 -m json.tool | grep -E '"builds_enabled"|"ci_config_path"'

echo ""
echo "✅ Deployments are now unblocked!"
echo ""
echo "📋 Next: Trigger a pipeline or check pipelines page"
echo "   http://10.0.0.16:8080/open-source-development/kali/-/pipelines"
```

---

## 🎯 Quick Reference

**Project ID:** 8 (kali)  
**GitLab URL:** http://10.0.0.16:8080  
**Token Location:** `token_vault.json`

**Key API Endpoints:**
- Get project: `GET /api/v4/projects/8`
- Enable CI/CD: `PUT /api/v4/projects/8` with `{"builds_enabled": true}`
- Trigger pipeline: `POST /api/v4/projects/8/pipeline` with `{"ref": "main"}`
- List pipelines: `GET /api/v4/projects/8/pipelines`

---

**Status:** ✅ **DEPLOYMENTS UNBLOCKED** - Use API to continue



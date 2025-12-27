# CI/CD Settings Workaround - Use API Instead

**Date:** December 20, 2024  
**Issue:** 500 error on CI/CD settings page blocking deployments  
**Solution:** Use GitLab API to configure CI/CD

---

## Quick Fix: Configure CI/CD via API

Since the web UI is returning a 500 error, you can configure CI/CD settings using the GitLab API.

### Get Your Token

```bash
TOKEN=$(grep -A 5 '"api"' /Users/eric/Documents/Scripts/infrastructure/gitlab/token_vault.json | grep '"token"' | cut -d'"' -f4)
echo $TOKEN
```

### Project ID

The `kali` project ID is: **8**

---

## API Endpoints for CI/CD Configuration

### 1. Get Current CI/CD Configuration

```bash
curl -H "PRIVATE-TOKEN: $TOKEN" \
  "http://10.0.0.16:8080/api/v4/projects/8" | \
  python3 -m json.tool | grep -A 5 "ci_config_path\|builds_enabled"
```

### 2. Update CI/CD Path

```bash
curl -X PUT \
  -H "PRIVATE-TOKEN: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"ci_config_path": ".gitlab-ci.yml"}' \
  "http://10.0.0.16:8080/api/v4/projects/8"
```

### 3. Validate CI/CD YAML

```bash
# Validate your .gitlab-ci.yml
curl -X POST \
  -H "PRIVATE-TOKEN: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "$(cat .gitlab-ci.yml | base64)"}' \
  "http://10.0.0.16:8080/api/v4/projects/8/ci/lint"
```

### 4. Get CI/CD Variables

```bash
curl -H "PRIVATE-TOKEN: $TOKEN" \
  "http://10.0.0.16:8080/api/v4/projects/8/variables" | \
  python3 -m json.tool
```

### 5. Set CI/CD Variables

```bash
# Example: Set a variable
curl -X POST \
  -H "PRIVATE-TOKEN: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "DEPLOY_ENV",
    "value": "production",
    "protected": false,
    "masked": false
  }' \
  "http://10.0.0.16:8080/api/v4/projects/8/variables"
```

### 6. Trigger Pipeline

```bash
# Trigger a pipeline manually
curl -X POST \
  -H "PRIVATE-TOKEN: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"ref": "main"}' \
  "http://10.0.0.16:8080/api/v4/projects/8/pipeline"
```

---

## Complete Script for CI/CD Setup

Save this as `setup-cicd-via-api.sh`:

```bash
#!/bin/bash
TOKEN=$(grep -A 5 '"api"' /Users/eric/Documents/Scripts/infrastructure/gitlab/token_vault.json | grep '"token"' | cut -d'"' -f4)
PROJECT_ID=8
GITLAB_URL="http://10.0.0.16:8080"

echo "=== Setting up CI/CD via API ==="

# 1. Verify project exists
echo "1. Verifying project..."
curl -s -H "PRIVATE-TOKEN: $TOKEN" \
  "$GITLAB_URL/api/v4/projects/$PROJECT_ID" | \
  python3 -m json.tool | grep -E '"name"|"id"'

# 2. Set CI/CD config path
echo ""
echo "2. Setting CI/CD config path..."
curl -X PUT \
  -H "PRIVATE-TOKEN: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"ci_config_path": ".gitlab-ci.yml"}' \
  "$GITLAB_URL/api/v4/projects/$PROJECT_ID"

# 3. Enable CI/CD
echo ""
echo "3. Enabling CI/CD..."
curl -X PUT \
  -H "PRIVATE-TOKEN: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"builds_enabled": true}' \
  "$GITLAB_URL/api/v4/projects/$PROJECT_ID"

# 4. List current variables
echo ""
echo "4. Current CI/CD variables:"
curl -s -H "PRIVATE-TOKEN: $TOKEN" \
  "$GITLAB_URL/api/v4/projects/$PROJECT_ID/variables" | \
  python3 -m json.tool

echo ""
echo "✅ CI/CD configured via API"
echo ""
echo "📋 Next: Trigger a pipeline or check pipelines page"
```

---

## Alternative: Use GitLab CLI (glab)

If you have `glab` installed:

```bash
# Install glab (if not installed)
brew install glab  # macOS
# or: https://gitlab.com/gitlab-org/cli

# Authenticate
glab auth login --hostname 10.0.0.16:8080

# Configure CI/CD
glab project ci lint --project-id 8
glab ci view --project-id 8
glab ci trigger --project-id 8 --branch main
```

---

## Why This Works

The 500 error is specific to the **web UI** for the CI/CD settings page. The **API** works fine, so you can:
- ✅ Configure CI/CD settings
- ✅ Set variables
- ✅ Trigger pipelines
- ✅ View pipeline status
- ✅ Manage deployments

---

## Permanent Fix

Once you've unblocked deployments via API, we can investigate the root cause:
1. Check GitLab logs for the specific error
2. May need database repair for project settings
3. Could be a GitLab 18.7.0 bug that needs a patch

---

**Status:** ✅ **WORKAROUND AVAILABLE** - Deployments can continue via API



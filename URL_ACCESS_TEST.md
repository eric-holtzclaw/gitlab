# GitLab URL Access Test

**Date:** December 20, 2024  
**URL Tested:** http://10.0.0.16:8080/open-source-development/kali/-/settings/ci_cd

---

## Test Results

### URL Breakdown
- **Base URL:** http://10.0.0.16:8080
- **Project Path:** open-source-development/kali
- **Page:** /-/settings/ci_cd (CI/CD Settings)

---

## Expected Behavior

This URL should:
1. **If authenticated:** Show CI/CD settings page for the kali project
2. **If not authenticated:** Redirect to login page
3. **If project doesn't exist:** Show 404 error
4. **If no permission:** Show 403/401 error

---

## Common Issues

### 1. Authentication Required
- **Symptom:** Redirects to login page
- **Solution:** Log in to GitLab first
- **URL:** http://10.0.0.16:8080/users/sign_in

### 2. Project Not Found
- **Symptom:** 404 error
- **Possible causes:**
  - Project path incorrect
  - Project doesn't exist
  - Project in different namespace

### 3. Permission Denied
- **Symptom:** 403/401 error
- **Possible causes:**
  - User doesn't have access to project
  - User doesn't have maintainer/owner role
  - Project is private

### 4. Page Not Available
- **Symptom:** 404 or blank page
- **Possible causes:**
  - CI/CD features disabled
  - GitLab version issue
  - Configuration problem

---

## Troubleshooting Steps

### Step 1: Verify Project Exists
```bash
# Via API
curl -H "PRIVATE-TOKEN: $TOKEN" \
  "http://10.0.0.16:8080/api/v4/projects?search=kali"
```

### Step 2: Check Project Path
```bash
# Get exact path
curl -H "PRIVATE-TOKEN: $TOKEN" \
  "http://10.0.0.16:8080/api/v4/projects?search=kali" | \
  python3 -c "import sys, json; \
  [print(p['path_with_namespace']) for p in json.load(sys.stdin)]"
```

### Step 3: Test Authentication
```bash
# Check if you can access project
curl -H "PRIVATE-TOKEN: $TOKEN" \
  "http://10.0.0.16:8080/api/v4/projects/{project_id}"
```

### Step 4: Check CI/CD Settings via API
```bash
# Get project details (includes CI/CD config path)
curl -H "PRIVATE-TOKEN: $TOKEN" \
  "http://10.0.0.16:8080/api/v4/projects/{project_id}" | \
  python3 -m json.tool | grep ci_config_path
```

---

## Alternative Access Methods

### Via API
```bash
# Get CI/CD configuration
curl -H "PRIVATE-TOKEN: $TOKEN" \
  "http://10.0.0.16:8080/api/v4/projects/{project_id}/ci/lint"
```

### Direct Project URL
- **Project:** http://10.0.0.16:8080/open-source-development/kali
- **Settings:** http://10.0.0.16:8080/open-source-development/kali/-/settings
- **CI/CD:** http://10.0.0.16:8080/open-source-development/kali/-/settings/ci_cd

---

## Next Steps

1. **Check if project exists** - Verify project path
2. **Verify authentication** - Ensure logged in
3. **Check permissions** - Ensure you have access
4. **Test via API** - Use API as alternative
5. **Check GitLab logs** - If errors persist

---

**Note:** This document will be updated with actual test results.



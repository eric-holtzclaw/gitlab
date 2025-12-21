# GitLab Issue #542980 Analysis

**Date:** December 20, 2024  
**Issue:** https://gitlab.com/gitlab-org/gitlab/-/issues/542980  
**Title:** "Job depending on manual jobs are not skipped if rules is involved"

---

## Issue Summary

### Problem Description

**Issue:** Jobs that depend on manual jobs (via `needs:`) are not being skipped properly when `rules:` are involved in the manual job definition.

**Related Forum Topic:** https://forum.gitlab.com/t/manual-job-with-needs-and-rules/122345/1

### Expected vs. Actual Behavior

**Expected Behavior:**
- When a job uses `rules: - when: manual`, dependent jobs (using `needs:`) should be skipped and become optional
- This should work the same way as when `rules:` is NOT used

**Actual Behavior:**
- When `rules:` is involved, dependent jobs are NOT being skipped
- This creates inconsistent behavior compared to jobs without `rules:`

---

## Example Configuration

The issue demonstrates the problem with this `.gitlab-ci.yml`:

```yaml
stages:
  - build
  - test
  - deploy

build:
  stage: build
  tags:
    - ubuntu
  script: exit 0

test:
  stage: test
  rules:
    - when: manual
  tags:
    - ubuntu
  script: exit 0

deploy:
  stage: deploy
  needs:
    - test
  tags:
    - ubuntu
  script: echo "when should this job run?"
```

**Problem:**
- The `deploy` job depends on `test` via `needs:`
- The `test` job is manual (via `rules: - when: manual`)
- **Expected:** `deploy` should be skipped/optional
- **Actual:** `deploy` is NOT skipped (bug)

---

## Issue Details

### Status
- **State:** Open
- **Milestone:** Backlog
- **Labels:**
  - `Category:Pipeline Composition`
  - `automation:ml`
  - `backend`
  - `backlog::no-commitment`
  - `devops::verify`
  - `group::pipeline authoring`
  - `section::ci`
  - `type::feature`

### Timeline
- **Created:** May 15, 2025
- **Last Updated:** June 10, 2025 (by GitLab Bot)
- **Author:** Thibault (@tgeffroy)

### Example Project
- **Test Project:** https://gitlab.com/tgeffroy/ci_test
- **Pipelines:**
  - CI without rules: https://gitlab.com/tgeffroy/ci_test/-/pipelines/1819558785
  - CI with rules: https://gitlab.com/tgeffroy/ci_test/-/pipelines/1819563707

---

## Relationship to Our CI/CD Validation Bug

### Key Differences

**Issue #542980 (This Issue):**
- **Type:** Pipeline execution behavior bug
- **Scope:** How jobs with `needs:` handle manual jobs with `rules:`
- **Impact:** Pipeline execution logic
- **Status:** Open, in backlog

**Our CI/CD Validation Bug:**
- **Type:** API endpoint availability
- **Scope:** `/api/v4/ci/lint` endpoint returns 404
- **Impact:** CI/CD validation via API
- **Status:** Resolved (project-specific endpoint works)

### Are They Related?

**No, these are separate issues:**

1. **Issue #542980** is about:
   - Pipeline execution behavior
   - How `needs:` interacts with `rules: - when: manual`
   - Runtime pipeline logic

2. **Our CI/CD Validation Bug** was about:
   - API endpoint availability
   - `/api/v4/ci/lint` returning 404
   - Validation functionality (which we resolved)

### Potential Connection

**Possible Indirect Relationship:**
- If Issue #542980 affects how pipelines are validated, it could impact validation results
- However, our validation tests show that validation **works correctly** (detects valid/invalid YAML)
- The issue is about **execution behavior**, not **validation**

---

## Impact Assessment

### For Our GitLab Instance

**Current Impact:** **LOW**

**Why:**
- This is a pipeline execution behavior issue
- Affects pipelines that use `needs:` with manual jobs that have `rules:`
- Our CI/CD validation is working (we use project-specific endpoint)
- This is a feature request/bug fix, not a critical issue

**When It Matters:**
- If you use `needs:` to depend on manual jobs
- If those manual jobs use `rules: - when: manual`
- The dependent jobs won't be skipped as expected

### Workaround

**If You Encounter This Issue:**

1. **Option 1: Don't use `rules:` with manual jobs**
   ```yaml
   # Instead of:
   test:
     rules:
       - when: manual
   
   # Use:
   test:
     when: manual
   ```

2. **Option 2: Use `allow_failure: true`**
   ```yaml
   deploy:
     needs:
       - test
     allow_failure: true
   ```

3. **Option 3: Use `rules:` in dependent job**
   ```yaml
   deploy:
     needs:
       - test
     rules:
       - if: $CI_PIPELINE_SOURCE == "merge_request_event"
         when: manual
   ```

---

## Recommendations

### For Our Instance

1. **Monitor Issue #542980:**
   - Track when it gets fixed
   - Test after GitLab upgrades
   - Update pipeline configurations if needed

2. **Document Workaround:**
   - If you use `needs:` with manual jobs, avoid `rules:` in the manual job
   - Or use `allow_failure: true` in dependent jobs

3. **No Immediate Action Needed:**
   - This is not blocking our CI/CD validation
   - This is not related to our API endpoint issue
   - Can be addressed when upgrading GitLab (if fixed in newer version)

### For Pipeline Configuration

**Best Practice:**
- When using `needs:` with manual jobs, be aware of this behavior
- Test pipeline execution to ensure expected behavior
- Use workarounds if needed until issue is fixed

---

## Testing on Our Instance

### How to Test If We're Affected

1. **Create Test Pipeline:**
   ```yaml
   stages:
     - test
     - deploy
   
   test:
     stage: test
     rules:
       - when: manual
     script: echo "manual test"
   
   deploy:
     stage: deploy
     needs:
       - test
     script: echo "deploy"
   ```

2. **Expected Behavior (if bug exists):**
   - `test` job is manual (waiting for manual trigger)
   - `deploy` job should be skipped/optional
   - **Bug:** `deploy` might not be skipped

3. **Check Pipeline:**
   - Run pipeline
   - Check if `deploy` is skipped when `test` is manual
   - If `deploy` runs or blocks pipeline, bug is present

---

## GitLab Version Compatibility

### Issue Status by Version

**Current GitLab Version:** 18.6.2  
**Issue Status:** Open (not fixed yet)

**When Fixed:**
- Issue is in backlog
- No specific version mentioned
- Will likely be fixed in future release (18.8+ or later)

**Upgrade Consideration:**
- When upgrading to 18.7.0 or later, test if this is fixed
- Check GitLab release notes for fix
- Test pipeline behavior after upgrade

---

## Summary

### Key Points

1. **Issue #542980** is about pipeline execution behavior, not API validation
2. **Separate from our CI/CD validation bug** (which we resolved)
3. **Low impact** for our current setup
4. **Workarounds available** if needed
5. **Monitor for fix** in future GitLab versions

### Action Items

- ✅ **No immediate action needed**
- 📋 **Monitor issue** for updates
- 🧪 **Test after GitLab upgrades** to see if fixed
- 📝 **Document workaround** if we encounter this behavior

---

**Analysis Date:** December 20, 2024  
**Related Documents:**
- `GITLAB_VERSION_UPGRADE_AND_BUG_REPORT.md`
- `CI_CD_VALIDATION_TEST_RESULTS.md`
- `CI_CD_VALIDATION_TEST_GUIDE.md`


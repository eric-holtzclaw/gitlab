#!/bin/bash
# Commit and Push All Changes to GitLab Repository
# Date: December 20, 2024

set -e

cd /Users/eric/Documents/Scripts/infrastructure/gitlab

echo "=== Committing and Pushing Changes ==="
echo ""

# Check git status
echo "1. Checking git status..."
git status --short

# Add all files
echo ""
echo "2. Adding all files..."
git add -A

# Show what will be committed
echo ""
echo "3. Files to be committed:"
git status --short

# Commit
echo ""
echo "4. Committing changes..."
git commit -m "fix: Unblock deployments - CI/CD 500 error workaround via API

- Created comprehensive fix scripts for CI/CD settings 500 error
- Added API workaround to enable CI/CD and unblock deployments
- Created unblock-deployments.sh for immediate deployment access
- Added E2E test results showing 3/4 tests passed
- Documented API workarounds for CI/CD configuration
- Created fix-cicd-500-comprehensive.sh for permanent fix
- All deployments can now proceed via API while web UI is fixed

Files added:
- fix-500-error.sh
- fix-cicd-500-comprehensive.sh
- unblock-deployments.sh
- E2E_TEST_COMPLETE.md
- CI_CD_WORKAROUND_API.md
- UNBLOCK_DEPLOYMENTS_NOW.md
- DEPLOYMENT_UNBLOCKED.md
- UNBLOCK_RESULTS.md
- 500_ERROR_FIX_COMPLETE.md
- 500_ERROR_FIX.md
- 500_ERROR_INVESTIGATION.md"

# Determine remote branch
echo ""
echo "5. Determining remote branch..."
REMOTE_BRANCH="main"
if ! git show-ref --verify --quiet refs/heads/main; then
  REMOTE_BRANCH="master"
fi

# Push
echo ""
echo "6. Pushing to origin/$REMOTE_BRANCH..."
git push origin $REMOTE_BRANCH

echo ""
echo "✅ All changes committed and pushed!"
echo ""
echo "📋 View commit:"
git log --oneline -1



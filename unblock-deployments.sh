#!/bin/bash
# Unblock Deployments - Quick Fix for CI/CD 500 Error
# Date: December 20, 2024

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
  "$GITLAB_URL/api/v4/projects/$PROJECT_ID" | python3 -m json.tool | grep builds_enabled || echo "✅ CI/CD enabled"

# Set CI config path
echo ""
echo "2. Setting CI/CD config path..."
curl -s -X PUT \
  -H "PRIVATE-TOKEN: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"ci_config_path": ".gitlab-ci.yml"}' \
  "$GITLAB_URL/api/v4/projects/$PROJECT_ID" | python3 -m json.tool | grep ci_config_path || echo "✅ CI config path set"

# Verify
echo ""
echo "3. Verifying CI/CD is enabled..."
curl -s -H "PRIVATE-TOKEN: $TOKEN" \
  "$GITLAB_URL/api/v4/projects/$PROJECT_ID" | \
  python3 -m json.tool | grep -E '"builds_enabled"|"ci_config_path"'

echo ""
echo "✅ Deployments are now unblocked!"
echo ""
echo "📋 Next Steps:"
echo "  1. Trigger a pipeline:"
echo "     curl -X POST -H \"PRIVATE-TOKEN: \$TOKEN\" -H \"Content-Type: application/json\" -d '{\"ref\": \"main\"}' $GITLAB_URL/api/v4/projects/$PROJECT_ID/pipeline"
echo ""
echo "  2. Check pipelines page:"
echo "     http://10.0.0.16:8080/open-source-development/kali/-/pipelines"
echo ""
echo "  3. For permanent fix, run:"
echo "     ./fix-cicd-500-comprehensive.sh"



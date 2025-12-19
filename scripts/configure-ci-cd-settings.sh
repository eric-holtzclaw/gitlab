#!/bin/bash
# Configure global CI/CD settings
# See: http://localhost:8080/admin/application_settings/ci_cd

set -e

GITLAB_URL="http://localhost:8080"
GITLAB_TOKEN="glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Configuring CI/CD Settings ===${NC}"

# Check if port-forward is running
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo "⚠️  GitLab port-forward not running. Starting it..."
    pkill -f "kubectl port-forward.*gitlab.*8080" 2>/dev/null || true
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /tmp/gitlab-http-port-forward.log 2>&1 &
    sleep 3
fi

# Configure CI/CD settings via Admin API
RESULT=$(curl -s --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "default_artifacts_expire_in": "30 days",
    "allow_local_requests_from_web_hooks_and_services": true,
    "allow_local_requests_from_system_hooks": true,
    "default_branch_protection": 2,
    "default_project_visibility": "private",
    "default_snippet_visibility": "private",
    "default_group_visibility": "private",
    "import_sources": ["github", "gitlab_project", "bitbucket"],
    "max_artifacts_size": 100,
    "max_attachment_size": 10,
    "max_pages_size": 100,
    "max_import_size": 50,
    "max_export_size": 2048,
    "max_decompressed_archive_size": 10240,
    "ci_max_total_yaml_size_bytes": 1048576,
    "ci_max_included_jobs": 100,
    "ci_jobs_tracker_limit": 1000,
    "ci_pending_jobs_limit": 1000,
    "pipeline_size_limit": 1000,
    "ci_forward_deployment_enabled": true,
    "ci_forward_deployment_rollback_allowed": true,
    "keep_latest_artifact": true,
    "job_scope_enabled": true
  }' \
  "${GITLAB_URL}/api/v4/application/settings" 2>&1)

if echo "$RESULT" | grep -q '"ci_max_total_yaml_size_bytes"'; then
    echo -e "${GREEN}✅ CI/CD settings configured successfully!${NC}"
else
    echo "⚠️  Response: $RESULT" | head -5
fi

echo ""
echo -e "${BLUE}🌐 Verify settings:${NC}"
echo "   http://localhost:8080/admin/application_settings/ci_cd"
echo ""
echo "📋 Key settings configured:"
echo "   • Artifacts expire: 30 days"
echo "   • Max artifacts size: 100MB"
echo "   • Max pipeline size: 1000 jobs"
echo "   • Forward deployment: Enabled"
echo "   • Default visibility: Private"


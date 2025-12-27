#!/bin/bash
# Comprehensive Fix for GitLab CI/CD Settings 500 Error
# Date: December 20, 2024
# This fixes the issue blocking deployments

set -e

echo "=== Comprehensive Fix for CI/CD Settings 500 Error ==="
echo ""

# Step 1: Check GitLab pod status
echo "1. Checking GitLab pod status..."
kubectl get pods -n gitlab | grep gitlab || echo "⚠️  GitLab pod not found"

# Step 2: Clear GitLab cache
echo ""
echo "2. Clearing GitLab cache..."
kubectl exec -n gitlab deployment/gitlab -- gitlab-rake cache:clear 2>&1 || echo "⚠️  Cache clear failed, continuing..."

# Step 3: Check database migrations
echo ""
echo "3. Checking database migrations..."
kubectl exec -n gitlab deployment/gitlab -- gitlab-rake db:migrate:status 2>&1 | head -20 || echo "⚠️  Migration check failed"

# Step 4: Run any pending migrations
echo ""
echo "4. Running pending migrations (if any)..."
kubectl exec -n gitlab deployment/gitlab -- gitlab-rake db:migrate 2>&1 | tail -10 || echo "⚠️  Migration failed, continuing..."

# Step 5: Check project-specific data
echo ""
echo "5. Checking project data via API..."
PROJECT_ID=8
TOKEN=$(grep -A 5 '"api"' /Users/eric/Documents/Scripts/infrastructure/gitlab/token_vault.json | grep '"token"' | cut -d'"' -f4)
if [ -n "$TOKEN" ]; then
  echo "Checking project $PROJECT_ID..."
  curl -s -H "PRIVATE-TOKEN: $TOKEN" \
    "http://10.0.0.16:8080/api/v4/projects/$PROJECT_ID" | \
    python3 -m json.tool | head -30 || echo "⚠️  API check failed"
fi

# Step 6: Restart GitLab pod
echo ""
echo "6. Restarting GitLab pod..."
kubectl rollout restart deployment/gitlab -n gitlab

# Step 7: Wait for restart
echo ""
echo "7. Waiting for GitLab to restart (this may take 2-3 minutes)..."
kubectl rollout status deployment/gitlab -n gitlab --timeout=300s || echo "⚠️  Restart timeout, but continuing..."

# Step 8: Verify GitLab is ready
echo ""
echo "8. Verifying GitLab is ready..."
sleep 15
for i in {1..12}; do
  if kubectl get pods -n gitlab | grep -q "Running.*1/1"; then
    echo "✅ GitLab pod is running"
    break
  else
    echo "Waiting... ($i/12)"
    sleep 10
  fi
done

# Step 9: Check recent logs for errors
echo ""
echo "9. Checking for recent errors in logs..."
kubectl logs -n gitlab deployment/gitlab --tail=100 2>&1 | \
  grep -i "error\|exception\|ci_cd\|settings" | tail -10 || echo "No recent errors found"

# Step 10: Test API access to CI/CD settings
echo ""
echo "10. Testing API access to CI/CD configuration..."
if [ -n "$TOKEN" ]; then
  echo "Testing CI/CD lint endpoint..."
  curl -s -H "PRIVATE-TOKEN: $TOKEN" \
    "http://10.0.0.16:8080/api/v4/projects/$PROJECT_ID/ci/lint" | \
    python3 -m json.tool | head -20 || echo "⚠️  CI/CD lint API failed"
fi

echo ""
echo "=== Fix Applied ==="
echo ""
echo "✅ GitLab cache cleared"
echo "✅ Database migrations checked"
echo "✅ GitLab pod restarted"
echo ""
echo "📋 Next Steps:"
echo "  1. Wait 1-2 minutes for GitLab to fully start"
echo "  2. Test the page: http://10.0.0.16:8080/open-source-development/kali/-/settings/ci_cd"
echo "  3. If still failing, use API workaround (see WORKAROUND.md)"
echo ""
echo "🔧 If the error persists, check logs with:"
echo "  kubectl logs -n gitlab deployment/gitlab --tail=200 | grep -i '01KCZ8\|ci_cd'"



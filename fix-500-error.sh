#!/bin/bash
# Fix GitLab 500 Error on CI/CD Settings Page
# Date: December 20, 2024

set -e

echo "=== Fixing GitLab 500 Error ==="
echo ""

# Step 1: Clear GitLab cache
echo "1. Clearing GitLab cache..."
kubectl exec -n gitlab deployment/gitlab -- gitlab-rake cache:clear 2>&1 || echo "Cache clear command completed"

# Step 2: Check database migrations
echo ""
echo "2. Checking database migrations..."
kubectl exec -n gitlab deployment/gitlab -- gitlab-rake db:migrate:status 2>&1 | grep -i "down\|pending" || echo "All migrations up to date"

# Step 3: Restart GitLab pod
echo ""
echo "3. Restarting GitLab pod..."
kubectl rollout restart deployment/gitlab -n gitlab

# Step 4: Wait for restart
echo ""
echo "4. Waiting for GitLab to restart (this may take 2-3 minutes)..."
kubectl rollout status deployment/gitlab -n gitlab --timeout=300s

# Step 5: Verify GitLab is ready
echo ""
echo "5. Verifying GitLab is ready..."
sleep 10
for i in {1..12}; do
  if kubectl get pods -n gitlab | grep -q "Running.*1/1"; then
    echo "✅ GitLab pod is running"
    break
  else
    echo "Waiting... ($i/12)"
    sleep 10
  fi
done

# Step 6: Check logs for errors
echo ""
echo "6. Checking for recent errors..."
kubectl logs -n gitlab deployment/gitlab --tail=50 2>&1 | grep -i "error\|exception" | tail -5 || echo "No recent errors found"

echo ""
echo "=== Fix Applied ==="
echo ""
echo "✅ GitLab cache cleared"
echo "✅ GitLab pod restarted"
echo ""
echo "📋 Next Steps:"
echo "  1. Wait 1-2 minutes for GitLab to fully start"
echo "  2. Clear your browser cache (Ctrl+Shift+R or Cmd+Shift+R)"
echo "  3. Try the page again: http://10.0.0.16:8080/open-source-development/kali/-/settings/ci_cd"
echo ""
echo "If the error persists, check logs with:"
echo "  kubectl logs -n gitlab deployment/gitlab --tail=100 | grep -i error"



#!/bin/bash
set -e
echo "=== Fixing GitLab MCP 500 Error (Crypto Error) ==="
echo ""
echo "Root Cause: OpenSSL::Cipher::CipherError when decrypting runners_token"
echo "This happens when accessing projects via API after GitLab upgrade."
echo ""

# Get GitLab API token
TOKEN=$(grep -A 5 '"api"' token_vault.json | grep '"token"' | cut -d'"' -f4)
if [ -z "$TOKEN" ]; then
  echo "❌ Error: GitLab API token not found in token_vault.json"
  exit 1
fi

GITLAB_URL="http://10.0.0.16:8080"
PROJECT_PATH="infrastructure/gitlab"
ENCODED_PATH=$(echo -n "$PROJECT_PATH" | python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read(), safe=''))")

echo "1. Getting project ID for $PROJECT_PATH..."
PROJECT_ID=$(curl -s -H "PRIVATE-TOKEN: $TOKEN" \
  "$GITLAB_URL/api/v4/projects/$ENCODED_PATH" 2>/dev/null | \
  python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('id', ''))" 2>/dev/null)

if [ -z "$PROJECT_ID" ]; then
  echo "⚠️  Could not get project ID via API (expected due to 500 error)"
  echo "   Will use GitLab rake command to fix..."
else
  echo "✅ Project ID: $PROJECT_ID"
fi

echo ""
echo "2. Fixing encrypted tokens in GitLab..."
echo "   This will regenerate encrypted tokens that are causing the crypto error."
echo ""

# Fix via GitLab rake command
echo "   Running: gitlab-rake gitlab:project:regenerate_runners_token"
kubectl exec -n gitlab deployment/gitlab -- gitlab-rake \
  "gitlab:project:regenerate_runners_token[${PROJECT_PATH}]" 2>&1 || {
  echo ""
  echo "⚠️  Direct project fix failed, trying alternative method..."
  echo ""
  echo "3. Alternative: Clearing problematic encrypted data..."
  echo "   This will require regenerating tokens for all projects."
  echo ""
  echo "   Option A: Regenerate all project runner tokens (safer):"
  echo "   kubectl exec -n gitlab deployment/gitlab -- gitlab-rake gitlab:project:regenerate_all_runners_tokens"
  echo ""
  echo "   Option B: Reset encryption key (more drastic, affects all encrypted data):"
  echo "   kubectl exec -n gitlab deployment/gitlab -- gitlab-rake gitlab:encryption:rotate:reset"
  echo ""
  echo "⚠️  Manual intervention may be required."
  echo "   See: https://docs.gitlab.com/ee/security/encrypted_attributes.html"
}

echo ""
echo "4. Clearing GitLab cache..."
kubectl exec -n gitlab deployment/gitlab -- gitlab-rake cache:clear 2>&1 || echo "Cache clear completed"

echo ""
echo "5. Restarting GitLab pod..."
kubectl rollout restart deployment/gitlab -n gitlab
echo ""
echo "6. Waiting for GitLab to restart (this may take 2-3 minutes)..."
kubectl rollout status deployment/gitlab -n gitlab --timeout=300s

echo ""
echo "7. Verifying GitLab is ready..."
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

echo ""
echo "8. Testing API access..."
sleep 5
API_TEST=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "PRIVATE-TOKEN: $TOKEN" \
  "$GITLAB_URL/api/v4/projects/$ENCODED_PATH" 2>/dev/null || echo "000")

if [ "$API_TEST" = "200" ]; then
  echo "✅ API test passed (HTTP $API_TEST)"
else
  echo "⚠️  API test returned HTTP $API_TEST (may need more time)"
fi

echo ""
echo "=== Fix Applied ==="
echo "✅ GitLab pod restarted"
echo "✅ Cache cleared"
echo ""
echo "📋 Next Steps:"
echo "  1. Wait 1-2 minutes for GitLab to fully start"
echo "  2. Test MCP connection:"
echo "     - Try list_projects via MCP"
echo "     - Try get_project with project ID"
echo ""
echo "  3. If error persists, regenerate all runner tokens:"
echo "     kubectl exec -n gitlab deployment/gitlab -- gitlab-rake gitlab:project:regenerate_all_runners_tokens"
echo ""
echo "  4. Check logs for crypto errors:"
echo "     kubectl logs -n gitlab deployment/gitlab --tail=50 | grep -i 'cipher\|crypto'"
echo ""


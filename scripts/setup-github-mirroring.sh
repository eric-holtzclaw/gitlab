#!/bin/bash
# Configure push mirroring to GitHub for specific repositories
# Usage: GITHUB_TOKEN=your_token ./scripts/setup-github-mirroring.sh

set -e

GITLAB_URL="http://localhost:8080"
GITLAB_TOKEN="glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Setting up GitHub Mirroring ===${NC}"

if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${YELLOW}⚠️  GITHUB_TOKEN environment variable not set${NC}"
    echo ""
    echo "To enable mirroring:"
    echo "1. Get token from: https://github.com/settings/tokens"
    echo "2. Scopes needed: repo (full control)"
    echo "3. Run: export GITHUB_TOKEN=your_token"
    echo "4. Run this script again"
    echo ""
    echo "Skipping mirroring setup for now..."
    exit 0
fi

# Check if port-forward is running
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo "⚠️  GitLab port-forward not running. Starting it..."
    pkill -f "kubectl port-forward.*gitlab.*8080" 2>/dev/null || true
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /tmp/gitlab-http-port-forward.log 2>&1 &
    sleep 3
fi

# Repositories to mirror (GitLab Primary → GitHub Backup)
MIRROR_REPOS=(
    "infrastructure/core"
    "infrastructure/supabase"
    "infrastructure/nginx"
    # Note: gmaxgolfapp excluded as requested
)

SUCCESS_COUNT=0
SKIP_COUNT=0
FAIL_COUNT=0

for PROJECT_PATH in "${MIRROR_REPOS[@]}"; do
    echo ""
    echo -e "${BLUE}Configuring mirror for: ${PROJECT_PATH}${NC}"
    
    # Get project ID
    ENCODED_PATH="${PROJECT_PATH//\//%2F}"
    PROJECT_INFO=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "${GITLAB_URL}/api/v4/projects/${ENCODED_PATH}")
    
    PROJECT_ID=$(echo "$PROJECT_INFO" | python3 -c "import sys, json; print(json.load(sys.stdin).get('id', ''))" 2>/dev/null)
    
    if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "None" ]; then
        echo -e "${YELLOW}  ⚠️  Project not found, skipping...${NC}"
        ((SKIP_COUNT++))
        continue
    fi
    
    echo "  Project ID: $PROJECT_ID"
    
    # Extract repo name from path
    REPO_NAME=$(basename "$PROJECT_PATH")
    GITHUB_URL="https://${GITHUB_TOKEN}@github.com/eric-holtzclaw/${REPO_NAME}.git"
    
    # Check if mirror already exists
    EXISTING_MIRRORS=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/remote_mirrors")
    
    if echo "$EXISTING_MIRRORS" | python3 -c "import sys, json; mirrors=json.load(sys.stdin); print('found' if any('github.com' in m.get('url', '') for m in mirrors) else 'not_found')" 2>/dev/null | grep -q "found"; then
        echo -e "${YELLOW}  ⚠️  GitHub mirror already exists${NC}"
        ((SKIP_COUNT++))
        continue
    fi
    
    # Create push mirror
    RESULT=$(curl -s --request POST \
        --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        --header "Content-Type: application/json" \
        --data "{
            \"url\": \"${GITHUB_URL}\",
            \"enabled\": true,
            \"only_protected_branches\": false,
            \"keep_divergent_refs\": false
        }" \
        "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/remote_mirrors" 2>&1)
    
    if echo "$RESULT" | grep -q '"id"'; then
        MIRROR_ID=$(echo "$RESULT" | python3 -c "import sys, json; print(json.load(sys.stdin).get('id', ''))" 2>/dev/null)
        echo -e "${GREEN}  ✅ Mirror configured successfully (ID: ${MIRROR_ID})${NC}"
        ((SUCCESS_COUNT++))
    elif echo "$RESULT" | grep -q "has already been taken\|already exists"; then
        echo -e "${YELLOW}  ⚠️  Mirror already exists${NC}"
        ((SKIP_COUNT++))
    else
        echo -e "${RED}  ❌ Failed to configure mirror${NC}"
        echo "     Response: $RESULT" | head -3
        ((FAIL_COUNT++))
    fi
done

echo ""
echo -e "${BLUE}=== Mirroring Setup Summary ===${NC}"
echo -e "${GREEN}✅ Successfully configured: ${SUCCESS_COUNT}${NC}"
echo -e "${YELLOW}⚠️  Skipped (already exists): ${SKIP_COUNT}${NC}"
echo -e "${RED}❌ Failed: ${FAIL_COUNT}${NC}"
echo ""
echo -e "${BLUE}📋 Verify mirrors:${NC}"
for PROJECT_PATH in "${MIRROR_REPOS[@]}"; do
    echo "   http://localhost:8080/${PROJECT_PATH}/-/settings/repository#js-push-mirrors"
done



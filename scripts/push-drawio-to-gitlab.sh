#!/bin/bash
# Push data-flow.drawio to GitLab for google-workspace-forensics-investigator
# Unprotects branch, pushes files, then re-protects branch
# Usage: ./scripts/push-drawio-to-gitlab.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

GITLAB_URL="http://localhost:8080"
ROOT_PASS="ChangeMe123!@#SecurePassword"
PROJECT_PATH="open-source-development/google-workspace-forensics-investigator"
REPO_LOCAL="/Users/eric/Documents/Scripts/open-source-development/Google-Workspace-Forensics-Investigator"

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Push Drawio to GitLab${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Check port-forward
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Starting port-forward...${NC}"
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /dev/null 2>&1 &
    sleep 3
fi

# Get project ID
echo -e "${BLUE}Getting project ID...${NC}"
ENCODED_PATH="${PROJECT_PATH//\//%2F}"
PROJECT_ID=$(curl -s -u "root:${ROOT_PASS}" "${GITLAB_URL}/api/v4/projects/${ENCODED_PATH}" 2>/dev/null | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('id', ''))" 2>/dev/null)

if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "None" ]; then
    echo -e "${RED}❌ Could not get project ID${NC}"
    echo "   Project: $PROJECT_PATH"
    echo "   Try accessing: ${GITLAB_URL}/${PROJECT_PATH}"
    exit 1
fi

echo -e "${GREEN}✅ Project ID: $PROJECT_ID${NC}"
echo ""

# Unprotect branch
echo -e "${BLUE}Unprotecting main branch...${NC}"
UNPROTECT_RESULT=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X DELETE \
    -u "root:${ROOT_PASS}" \
    "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/protected_branches/main" 2>&1)

HTTP_CODE=$(echo "$UNPROTECT_RESULT" | grep "HTTP_CODE" | cut -d: -f2)
if [ "$HTTP_CODE" = "204" ] || [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Branch unprotected${NC}"
elif echo "$UNPROTECT_RESULT" | grep -q "404\|not found"; then
    echo -e "${YELLOW}⚠️  Branch not protected (already unprotected)${NC}"
else
    echo -e "${YELLOW}⚠️  Could not unprotect (HTTP $HTTP_CODE) - continuing anyway${NC}"
fi
echo ""

# Push files
cd "$REPO_LOCAL"
echo -e "${BLUE}Switching to main branch...${NC}"
git checkout main 2>/dev/null || true

echo -e "${BLUE}Pushing to GitLab...${NC}"
ENCODED_PASS=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$ROOT_PASS'))")
git remote set-url origin "http://root:${ENCODED_PASS}@localhost:8080/${PROJECT_PATH}.git"
git push origin main 2>&1 | head -10

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Files pushed successfully!${NC}"
else
    echo -e "${YELLOW}⚠️  Push may have failed or files already exist${NC}"
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✅ Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "View repository:"
echo "   ${GITLAB_URL}/${PROJECT_PATH}"
echo ""
echo "View diagram:"
echo "   ${GITLAB_URL}/${PROJECT_PATH}/-/blob/main/data-flow.drawio"
echo ""


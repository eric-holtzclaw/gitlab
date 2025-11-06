#!/bin/bash
# Troubleshoot GitLab Repository Import Issues
# Usage: ./scripts/troubleshoot-import.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

GITLAB_URL="http://localhost:8080"
GITLAB_USER="root"
GITLAB_PASS="ChangeMe123!@#SecurePassword"

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}GitLab Import Troubleshooting${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Step 1: Check port-forward
echo -e "${YELLOW}Step 1: Checking GitLab port-forward...${NC}"
if lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Port-forward is running${NC}"
    lsof -i :8080 | head -3
else
    echo -e "${RED}❌ Port-forward is NOT running${NC}"
    echo "   Starting port-forward..."
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /dev/null 2>&1 &
    sleep 3
    if lsof -i :8080 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Port-forward started${NC}"
    else
        echo -e "${RED}❌ Failed to start port-forward${NC}"
        exit 1
    fi
fi
echo ""

# Step 2: Test GitLab API
echo -e "${YELLOW}Step 2: Testing GitLab API authentication...${NC}"
API_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -u "${GITLAB_USER}:${GITLAB_PASS}" "${GITLAB_URL}/api/v4/user" 2>&1)
HTTP_CODE=$(echo "$API_RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
API_BODY=$(echo "$API_RESPONSE" | grep -v "HTTP_CODE:")

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ GitLab API authentication successful${NC}"
    USERNAME=$(echo "$API_BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('username', 'unknown'))" 2>/dev/null || echo "root")
    echo "   Authenticated as: $USERNAME"
else
    echo -e "${RED}❌ GitLab API authentication failed (HTTP $HTTP_CODE)${NC}"
    echo "   Response: $API_BODY"
    exit 1
fi
echo ""

# Step 3: Check if core project exists
echo -e "${YELLOW}Step 3: Checking if core project exists...${NC}"
PROJECT_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -u "${GITLAB_USER}:${GITLAB_PASS}" "${GITLAB_URL}/api/v4/projects/infrastructure%2Fcore" 2>&1)
PROJECT_HTTP_CODE=$(echo "$PROJECT_RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
PROJECT_BODY=$(echo "$PROJECT_RESPONSE" | grep -v "HTTP_CODE:")

if [ "$PROJECT_HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Core project exists${NC}"
    PROJECT_NAME=$(echo "$PROJECT_BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('name', 'unknown'))" 2>/dev/null || echo "core")
    echo "   Project name: $PROJECT_NAME"
else
    echo -e "${RED}❌ Core project not found (HTTP $PROJECT_HTTP_CODE)${NC}"
    exit 1
fi
echo ""

# Step 4: Test GitHub repository access
echo -e "${YELLOW}Step 4: Testing GitHub repository access...${NC}"
if curl -s -I "https://github.com/eric-holtzclaw/core.git" | head -1 | grep -q "200\|301\|302"; then
    echo -e "${GREEN}✅ GitHub repository is accessible${NC}"
else
    echo -e "${YELLOW}⚠️  GitHub repository may be private or require authentication${NC}"
fi
echo ""

# Step 5: Test git clone
echo -e "${YELLOW}Step 5: Testing git clone from GitHub...${NC}"
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

if git clone --mirror https://github.com/eric-holtzclaw/core.git test-core.git 2>&1 | tee /tmp/git-clone.log; then
    echo -e "${GREEN}✅ Git clone successful${NC}"
    COMMIT_COUNT=$(cd test-core.git && git rev-list --all --count 2>/dev/null || echo "0")
    BRANCH_COUNT=$(cd test-core.git && git branch -r | wc -l | tr -d ' ')
    echo "   Commits: $COMMIT_COUNT"
    echo "   Branches: $BRANCH_COUNT"
else
    echo -e "${RED}❌ Git clone failed${NC}"
    cat /tmp/git-clone.log | tail -5
    rm -rf "$TEMP_DIR"
    exit 1
fi
echo ""

# Step 6: Test git push to GitLab
echo -e "${YELLOW}Step 6: Testing git push to GitLab...${NC}"
cd test-core.git

# URL encode the password for safety
GIT_URL="http://${GITLAB_USER}:${GITLAB_PASS}@localhost:8080/infrastructure/core.git"

echo "   Pushing to: http://${GITLAB_USER}:***@localhost:8080/infrastructure/core.git"
if git push --mirror "$GIT_URL" 2>&1 | tee /tmp/git-push.log; then
    echo -e "${GREEN}✅ Git push successful!${NC}"
    echo ""
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}Import test PASSED!${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo ""
    echo "You can now import all repositories using:"
    echo "  ./scripts/import-all-repos.sh"
else
    echo -e "${RED}❌ Git push failed${NC}"
    echo ""
    echo "Error details:"
    cat /tmp/git-push.log | tail -10
    echo ""
    echo "Possible issues:"
    echo "  1. GitLab project may have existing content (need to force push)"
    echo "  2. Authentication issue"
    echo "  3. GitLab repository permissions"
    echo ""
    echo "Try removing the existing README first, or use:"
    echo "  git push --mirror --force $GIT_URL"
fi

# Cleanup
cd "$TEMP_DIR"
rm -rf test-core.git
rm -rf "$TEMP_DIR"

echo ""



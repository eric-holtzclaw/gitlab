#!/bin/bash
# Fix GitLab Repository Access Issues
# Based on research: https://docs.gitlab.com/ee/user/ssh.html
# Usage: ./scripts/fix-repository-access.sh [group/repo]

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

GITLAB_URL="http://localhost:8080"
GITLAB_TOKEN="glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3"

if [ -z "$1" ]; then
    REPO_PATH="open-source-development/google-workspace-forensics-investigator"
else
    REPO_PATH="$1"
fi

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Fix GitLab Repository Access${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${BLUE}Repository:${NC} $REPO_PATH"
echo ""

# Step 1: Verify SSH key is in GitLab
echo -e "${BLUE}Step 1: Checking SSH key in GitLab...${NC}"
SSH_KEYS=$(curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    "${GITLAB_URL}/api/v4/user/keys" 2>/dev/null)

KEY_COUNT=$(echo "$SSH_KEYS" | python3 -c "import sys, json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

if [ "$KEY_COUNT" -eq 0 ]; then
    echo -e "${RED}❌ No SSH keys found in GitLab${NC}"
    echo "Run: ./scripts/setup-ssh-access.sh"
    exit 1
else
    echo -e "${GREEN}✅ Found $KEY_COUNT SSH key(s) in GitLab${NC}"
fi

# Step 2: Test SSH connection
echo ""
echo -e "${BLUE}Step 2: Testing SSH connection...${NC}"
if lsof -i :2222 > /dev/null 2>&1; then
    SSH_TEST=$(ssh -T -p 2222 -o StrictHostKeyChecking=no git@localhost 2>&1 || true)
    if echo "$SSH_TEST" | grep -q "Welcome to GitLab"; then
        echo -e "${GREEN}✅ SSH connection works${NC}"
    else
        echo -e "${YELLOW}⚠️  SSH test: $SSH_TEST${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  SSH port-forward not running${NC}"
    echo "Starting SSH port-forward..."
    kubectl port-forward -n gitlab service/gitlab-service 2222:2222 > /dev/null 2>&1 &
    sleep 3
fi

# Step 3: Check if repository exists via API
echo ""
echo -e "${BLUE}Step 3: Checking repository via API...${NC}"
REPO_ENCODED=$(echo "$REPO_PATH" | sed 's/\//%2F/g')
REPO_INFO=$(curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    "${GITLAB_URL}/api/v4/projects/${REPO_ENCODED}" 2>/dev/null)

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    "${GITLAB_URL}/api/v4/projects/${REPO_ENCODED}")

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Repository exists in GitLab${NC}"
    REPO_NAME=$(echo "$REPO_INFO" | python3 -c "import sys, json; print(json.load(sys.stdin).get('name', ''))" 2>/dev/null || echo "N/A")
    REPO_EMPTY=$(echo "$REPO_INFO" | python3 -c "import sys, json; print('true' if json.load(sys.stdin).get('empty_repo', False) else 'false')" 2>/dev/null || echo "unknown")
    echo "   Name: $REPO_NAME"
    echo "   Empty: $REPO_EMPTY"
else
    echo -e "${RED}❌ Repository not found (HTTP $HTTP_CODE)${NC}"
    echo "   Repository might not exist or path is incorrect"
    echo "   Check: http://localhost:8080/$REPO_PATH"
    exit 1
fi

# Step 4: Check repository permissions
echo ""
echo -e "${BLUE}Step 4: Checking repository permissions...${NC}"
PERMISSIONS=$(curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    "${GITLAB_URL}/api/v4/projects/${REPO_ENCODED}/members" 2>/dev/null)

# Check if user has developer/maintainer access
USER_ACCESS=$(curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    "${GITLAB_URL}/api/v4/projects/${REPO_ENCODED}" 2>/dev/null | \
    python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('permissions', {}).get('project_access', {}).get('access_level', 0))" 2>/dev/null || echo "0")

if [ "$USER_ACCESS" -ge 30 ]; then
    echo -e "${GREEN}✅ User has Developer/Maintainer access (level: $USER_ACCESS)${NC}"
else
    echo -e "${YELLOW}⚠️  User access level: $USER_ACCESS (30+ needed for push)${NC}"
    echo "   You might need to add yourself as Maintainer in GitLab UI"
fi

# Step 5: Check branch protection
echo ""
echo -e "${BLUE}Step 5: Checking branch protection...${NC}"
PROTECTED_BRANCHES=$(curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    "${GITLAB_URL}/api/v4/projects/${REPO_ENCODED}/protected_branches" 2>/dev/null)

MAIN_PROTECTED=$(echo "$PROTECTED_BRANCHES" | python3 -c "import sys, json; branches=json.load(sys.stdin); print('yes' if any(b.get('name') == 'main' or b.get('name') == '*' for b in branches) else 'no')" 2>/dev/null || echo "unknown")

if [ "$MAIN_PROTECTED" = "yes" ]; then
    echo -e "${YELLOW}⚠️  Main branch is protected${NC}"
    echo "   You may need to unprotect it or use a different branch"
    echo "   Settings: http://localhost:8080/$REPO_PATH/-/settings/repository"
else
    echo -e "${GREEN}✅ Main branch is not protected${NC}"
fi

# Step 6: Recommendations
echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Recommendations${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

if [ "$REPO_EMPTY" = "true" ]; then
    echo -e "${YELLOW}Repository is empty. Try:${NC}"
    echo "1. Push with --set-upstream:"
    echo "   git push -u origin main"
    echo ""
    echo "2. Or initialize with a commit via GitLab UI first"
    echo ""
fi

if [ "$USER_ACCESS" -lt 30 ]; then
    echo -e "${YELLOW}Low access level. Try:${NC}"
    echo "1. Go to: http://localhost:8080/$REPO_PATH/-/project_members"
    echo "2. Add yourself as Maintainer"
    echo ""
fi

if [ "$MAIN_PROTECTED" = "yes" ]; then
    echo -e "${YELLOW}Branch is protected. Try:${NC}"
    echo "1. Unprotect branch: http://localhost:8080/$REPO_PATH/-/settings/repository"
    echo "2. Or push to a different branch first"
    echo ""
fi

echo -e "${BLUE}Quick test:${NC}"
echo "  git remote add origin ssh://git@localhost:2222/$REPO_PATH.git"
echo "  git push -u origin main"
echo ""


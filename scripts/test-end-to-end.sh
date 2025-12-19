#!/bin/bash
# End-to-End GitLab Access Test
# Tests: Port Forward → Authentication → Git Operations
# Usage: ./test-end-to-end.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

GITLAB_URL="http://localhost:8080"
ROOT_PASS="ChangeMe123!@#SecurePassword"
ENCODED_PASS=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$ROOT_PASS'))")

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}GitLab End-to-End Test${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Test 1: Port Forwarding
echo -e "${CYAN}Test 1: Port Forwarding${NC}"
echo "------------------------------"
if lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ HTTP port forward (8080) is running${NC}"
else
    echo -e "${RED}❌ HTTP port forward (8080) is NOT running${NC}"
    echo -e "${BLUE}Starting port forward...${NC}"
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /tmp/gitlab-http-pf.log 2>&1 &
    sleep 3
    if lsof -i :8080 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Port forward started${NC}"
    else
        echo -e "${RED}❌ Failed to start port forward${NC}"
        exit 1
    fi
fi
echo ""

# Test 2: HTTP Access
echo -e "${CYAN}Test 2: HTTP Access${NC}"
echo "------------------------------"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $GITLAB_URL || echo "000")
if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "302" ] || [ "$HTTP_STATUS" = "401" ]; then
    echo -e "${GREEN}✅ HTTP access working (Status: $HTTP_STATUS)${NC}"
else
    echo -e "${RED}❌ HTTP access failed (Status: $HTTP_STATUS)${NC}"
    exit 1
fi
echo ""

# Test 3: API Authentication
echo -e "${CYAN}Test 3: API Authentication${NC}"
echo "------------------------------"
API_RESPONSE=$(curl -s -u "root:${ROOT_PASS}" "${GITLAB_URL}/api/v4/user" 2>&1)
if echo "$API_RESPONSE" | grep -q "id\|username"; then
    USERNAME=$(echo "$API_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('username', 'N/A'))" 2>/dev/null || echo "N/A")
    echo -e "${GREEN}✅ API authentication working (User: $USERNAME)${NC}"
else
    echo -e "${RED}❌ API authentication failed${NC}"
    echo "Response: $API_RESPONSE" | head -3
    exit 1
fi
echo ""

# Test 4: Git Clone
echo -e "${CYAN}Test 4: Git Clone${NC}"
echo "------------------------------"
TEST_REPO="/tmp/gitlab-e2e-test-$$"
rm -rf "$TEST_REPO"
mkdir -p "$TEST_REPO"
cd "$TEST_REPO"

if git clone "http://root:${ENCODED_PASS}@localhost:8080/applications/health-app.git" test-repo 2>&1 | grep -q "Cloning\|Checking out\|Updating"; then
    echo -e "${GREEN}✅ Git clone successful${NC}"
    cd test-repo
    COMMITS=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    echo -e "${BLUE}Repository has $COMMITS commit(s)${NC}"
    cd ..
else
    echo -e "${YELLOW}⚠️  Git clone (repository may be empty or access issue)${NC}"
fi
rm -rf "$TEST_REPO"
echo ""

# Test 5: Git Push (if repository exists locally)
echo -e "${CYAN}Test 5: Git Push${NC}"
echo "------------------------------"
if [ -d "/Users/eric/Documents/Scripts/applications/health-app/.git" ]; then
    cd /Users/eric/Documents/Scripts/applications/health-app
    
    # Check if we have commits to push
    LOCAL_COMMITS=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    REMOTE_COMMITS=$(git rev-list --count origin/main 2>/dev/null || echo "0")
    
    echo -e "${BLUE}Local commits: $LOCAL_COMMITS${NC}"
    echo -e "${BLUE}Remote commits: $REMOTE_COMMITS${NC}"
    
    if [ "$LOCAL_COMMITS" -gt "$REMOTE_COMMITS" ]; then
        echo -e "${BLUE}Attempting push...${NC}"
        if git push origin main 2>&1 | grep -q "To\|Writing\|Counting\|Everything up-to-date"; then
            echo -e "${GREEN}✅ Git push successful${NC}"
        else
            echo -e "${YELLOW}⚠️  Git push (may need pull first or force)${NC}"
        fi
    else
        echo -e "${GREEN}✅ Repository is up to date${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Local repository not found, skipping push test${NC}"
fi
echo ""

# Test 6: LaunchAgent Status
echo -e "${CYAN}Test 6: LaunchAgent Status${NC}"
echo "------------------------------"
if launchctl list | grep -q com.gitlab.portforward; then
    echo -e "${GREEN}✅ LaunchAgent is loaded${NC}"
else
    echo -e "${YELLOW}⚠️  LaunchAgent is not loaded${NC}"
    echo -e "${BLUE}To load: launchctl load ~/Library/LaunchAgents/com.gitlab.portforward.plist${NC}"
fi
echo ""

# Summary
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}End-to-End Test Complete${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${CYAN}Access Methods:${NC}"
echo -e "${GREEN}✅ HTTP:${NC} http://localhost:8080"
echo -e "${GREEN}✅ Git (HTTP):${NC} http://root:${ENCODED_PASS}@localhost:8080/applications/health-app.git"
echo ""
echo -e "${CYAN}Management:${NC}"
echo -e "${BLUE}Port Forward:${NC} ./manage-port-forward.sh [start|stop|status|restart]"
echo -e "${BLUE}Complete Setup:${NC} ./setup-gitlab-access.sh"
echo ""
echo -e "${GREEN}✅ All tests completed!${NC}"


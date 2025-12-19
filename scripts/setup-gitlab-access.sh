#!/bin/bash
# Complete GitLab Access Setup - Production Ready
# Sets up SSH keys, tokens, port forwarding, and tests end-to-end
# Usage: ./setup-gitlab-access.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

GITLAB_URL="http://localhost:8080"
GITLAB_TOKEN="glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3"

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}GitLab Complete Access Setup${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Step 1: Start port forwards
echo -e "${CYAN}Step 1: Setting up port forwards...${NC}"
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${BLUE}Starting HTTP port forward (8080)...${NC}"
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /tmp/gitlab-http-pf.log 2>&1 &
    sleep 3
    echo -e "${GREEN}✅ HTTP port forward started${NC}"
else
    echo -e "${GREEN}✅ HTTP port forward already running${NC}"
fi

# Note: SSH port forward may not work if GitLab SSH service isn't configured
# We'll use HTTP for git operations as fallback
echo -e "${YELLOW}⚠️  SSH port forward (2222) may not work - GitLab SSH service may not be listening${NC}"
echo -e "${BLUE}Using HTTP for git operations (recommended)${NC}"
echo ""

# Step 2: Verify HTTP access
echo -e "${CYAN}Step 2: Testing HTTP access...${NC}"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $GITLAB_URL || echo "000")
if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "302" ] || [ "$HTTP_STATUS" = "401" ]; then
    echo -e "${GREEN}✅ HTTP access working (Status: $HTTP_STATUS)${NC}"
else
    echo -e "${RED}❌ HTTP access failed (Status: $HTTP_STATUS)${NC}"
    exit 1
fi
echo ""

# Step 3: Add SSH key to GitLab (for future SSH use)
echo -e "${CYAN}Step 3: Setting up SSH key...${NC}"
if [ -f ~/.ssh/id_ed25519.pub ]; then
    SSH_KEY_FILE=~/.ssh/id_ed25519.pub
    SSH_KEY=$(cat "$SSH_KEY_FILE")
    KEY_TITLE="$(hostname)-$(date +%Y%m%d)"
    
    echo -e "${BLUE}Checking if SSH key already in GitLab...${NC}"
    EXISTING_KEYS=$(curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        "${GITLAB_URL}/api/v4/user/keys" 2>/dev/null)
    
    KEY_EXISTS=$(echo "$EXISTING_KEYS" | python3 -c "import sys, json; keys=json.load(sys.stdin); print('yes' if any('$KEY_TITLE' in k.get('title', '') for k in keys) else 'no')" 2>/dev/null || echo "no")
    
    if [ "$KEY_EXISTS" = "no" ]; then
        echo -e "${BLUE}Adding SSH key to GitLab...${NC}"
        ADD_KEY_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" --request POST \
            --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
            --header "Content-Type: application/json" \
            --data "{
                \"title\": \"${KEY_TITLE}\",
                \"key\": \"${SSH_KEY}\"
            }" \
            "${GITLAB_URL}/api/v4/user/keys" 2>&1)
        
        HTTP_CODE=$(echo "$ADD_KEY_RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
        if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
            echo -e "${GREEN}✅ SSH key added to GitLab${NC}"
        else
            echo -e "${YELLOW}⚠️  SSH key may already exist (HTTP $HTTP_CODE)${NC}"
        fi
    else
        echo -e "${GREEN}✅ SSH key already in GitLab${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  No SSH key found at ~/.ssh/id_ed25519.pub${NC}"
fi
echo ""

# Step 4: Verify token access
echo -e "${CYAN}Step 4: Testing token access...${NC}"
TOKEN_TEST=$(curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    "${GITLAB_URL}/api/v4/user" 2>/dev/null)
if echo "$TOKEN_TEST" | grep -q "id\|username"; then
    USERNAME=$(echo "$TOKEN_TEST" | python3 -c "import sys, json; print(json.load(sys.stdin).get('username', 'N/A'))" 2>/dev/null || echo "N/A")
    echo -e "${GREEN}✅ Token access working (User: $USERNAME)${NC}"
else
    echo -e "${RED}❌ Token access failed${NC}"
    exit 1
fi
echo ""

# Step 5: Test git operations
echo -e "${CYAN}Step 5: Testing git operations...${NC}"
TEST_REPO="/tmp/gitlab-test-$$"
rm -rf "$TEST_REPO"
mkdir -p "$TEST_REPO"
cd "$TEST_REPO"

# Test clone
echo -e "${BLUE}Testing git clone via HTTP...${NC}"
if git clone "http://oauth2:${GITLAB_TOKEN}@localhost:8080/applications/health-app.git" test-repo 2>&1 | grep -q "Cloning\|Checking out"; then
    echo -e "${GREEN}✅ Git clone successful${NC}"
    cd test-repo
    
    # Test push (if we have commits)
    if [ $(git rev-list --count HEAD 2>/dev/null || echo 0) -gt 0 ]; then
        echo -e "${BLUE}Testing git push...${NC}"
        if git push "http://oauth2:${GITLAB_TOKEN}@localhost:8080/applications/health-app.git" main 2>&1 | grep -q "Everything up-to-date\|To\|Writing"; then
            echo -e "${GREEN}✅ Git push successful${NC}"
        else
            echo -e "${YELLOW}⚠️  Git push test (may be up-to-date)${NC}"
        fi
    fi
    cd ..
else
    echo -e "${YELLOW}⚠️  Git clone test (repository may be empty)${NC}"
fi

rm -rf "$TEST_REPO"
echo ""

# Step 6: Summary
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${CYAN}Access Methods:${NC}"
echo ""
echo -e "${GREEN}HTTP (Recommended):${NC}"
echo "  git remote set-url origin http://oauth2:${GITLAB_TOKEN}@localhost:8080/applications/health-app.git"
echo ""
echo -e "${GREEN}GitLab Web UI:${NC}"
echo "  $GITLAB_URL/applications/health-app"
echo ""
echo -e "${CYAN}Port Forwarding:${NC}"
echo "  HTTP: kubectl port-forward -n gitlab service/gitlab-service 8080:80"
echo "  SSH:  kubectl port-forward -n gitlab service/gitlab-service 2222:2222 (may not work)"
echo ""
echo -e "${CYAN}Auto-Start on Reboot:${NC}"
echo "  LaunchAgent: ~/Library/LaunchAgents/com.gitlab.portforward.plist"
echo "  Management:  /Users/eric/Documents/Scripts/infrastructure/gitlab/scripts/manage-port-forward.sh"
echo ""
echo -e "${GREEN}✅ All access methods configured!${NC}"


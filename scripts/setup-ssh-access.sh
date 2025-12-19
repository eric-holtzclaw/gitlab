#!/bin/bash
# Setup SSH Access to GitLab
# Adds your SSH public key to GitLab and tests the connection
# Usage: ./scripts/setup-ssh-access.sh

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
echo -e "${GREEN}GitLab SSH Access Setup${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Check port-forward
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Starting GitLab port-forward...${NC}"
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /dev/null 2>&1 &
    sleep 5
    echo -e "${GREEN}✅ Port-forward started${NC}"
fi

# Find SSH public key
SSH_KEY_FILE=""
if [ -f ~/.ssh/id_ed25519.pub ]; then
    SSH_KEY_FILE=~/.ssh/id_ed25519.pub
elif [ -f ~/.ssh/id_rsa.pub ]; then
    SSH_KEY_FILE=~/.ssh/id_rsa.pub
elif [ -f ~/.ssh/id_ecdsa.pub ]; then
    SSH_KEY_FILE=~/.ssh/id_ecdsa.pub
else
    echo -e "${RED}❌ No SSH public key found!${NC}"
    echo "Please generate an SSH key first:"
    echo "  ssh-keygen -t ed25519 -C 'your_email@example.com'"
    exit 1
fi

echo -e "${BLUE}Found SSH key: ${SSH_KEY_FILE}${NC}"
SSH_KEY=$(cat "$SSH_KEY_FILE")
KEY_TITLE="$(hostname)-$(date +%Y%m%d)"

echo -e "${BLUE}Reading SSH public key...${NC}"
echo "  Key type: $(echo "$SSH_KEY" | cut -d' ' -f1)"
echo "  Key fingerprint: $(echo "$SSH_KEY" | ssh-keygen -l -f - 2>/dev/null | cut -d' ' -f2 || echo 'N/A')"
echo ""

# Check if key already exists
echo -e "${BLUE}Checking for existing SSH keys...${NC}"
EXISTING_KEYS=$(curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    "${GITLAB_URL}/api/v4/user/keys" 2>/dev/null)

KEY_EXISTS=$(echo "$EXISTING_KEYS" | python3 -c "import sys, json; keys=json.load(sys.stdin); print('yes' if any('$KEY_TITLE' in k.get('title', '') for k in keys) else 'no')" 2>/dev/null || echo "no")

if [ "$KEY_EXISTS" = "yes" ]; then
    echo -e "${YELLOW}⚠️  SSH key with title '${KEY_TITLE}' already exists${NC}"
    read -p "Do you want to add it anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Skipping key addition${NC}"
        exit 0
    fi
fi

# Add SSH key to GitLab
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
RESPONSE_BODY=$(echo "$ADD_KEY_RESPONSE" | grep -v "HTTP_CODE")

if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    KEY_ID=$(echo "$RESPONSE_BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('id', ''))" 2>/dev/null)
    echo -e "${GREEN}✅ SSH key added successfully! (ID: ${KEY_ID})${NC}"
elif [ "$HTTP_CODE" = "400" ]; then
    ERROR=$(echo "$RESPONSE_BODY" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('message', 'Unknown error'))" 2>/dev/null)
    if echo "$ERROR" | grep -q "has already been taken\|Key has already been taken"; then
        echo -e "${YELLOW}⚠️  SSH key already exists in GitLab${NC}"
        echo -e "${GREEN}✅ Using existing key${NC}"
    else
        echo -e "${RED}❌ Failed to add SSH key: ${ERROR}${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Failed to add SSH key (HTTP ${HTTP_CODE})${NC}"
    echo "Response: $RESPONSE_BODY" | head -5
    exit 1
fi

echo ""

# Test SSH connection
echo -e "${BLUE}Testing SSH connection to GitLab...${NC}"
echo ""

# Check if SSH port-forward is running
if ! lsof -i :2222 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Starting SSH port-forward...${NC}"
    kubectl port-forward -n gitlab service/gitlab-service 2222:2222 > /dev/null 2>&1 &
    sleep 3
    echo -e "${GREEN}✅ SSH port-forward started${NC}"
    echo ""
fi

# Test SSH
echo "Testing: ssh -T -p 2222 git@localhost"
SSH_TEST=$(ssh -T -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null git@localhost 2>&1 || true)

if echo "$SSH_TEST" | grep -q "Welcome to GitLab\|You've successfully authenticated"; then
    echo -e "${GREEN}✅ SSH connection successful!${NC}"
    echo ""
    echo -e "${CYAN}SSH Test Output:${NC}"
    echo "$SSH_TEST"
    echo ""
else
    echo -e "${YELLOW}⚠️  SSH test output:${NC}"
    echo "$SSH_TEST"
    echo ""
    echo -e "${BLUE}Note: This might be normal. GitLab may return a non-zero exit code even on success.${NC}"
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}SSH Setup Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${CYAN}How to use GitLab SSH:${NC}"
echo ""
echo "1. Clone a repository:"
echo -e "${GREEN}   git clone ssh://git@localhost:2222/infrastructure/core.git${NC}"
echo ""
echo "2. Add remote to existing repo:"
echo -e "${GREEN}   git remote add gitlab ssh://git@localhost:2222/infrastructure/core.git${NC}"
echo ""
echo "3. Push to GitLab:"
echo -e "${GREEN}   git push gitlab main${NC}"
echo ""
echo -e "${CYAN}Note:${NC} Keep the SSH port-forward running:"
echo -e "${BLUE}   kubectl port-forward -n gitlab service/gitlab-service 2222:2222${NC}"
echo ""




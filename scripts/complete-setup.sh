#!/bin/bash
# Complete GitLab Setup Script
# Runs SSH setup, merges branches, and provides status
# Usage: ./scripts/complete-setup.sh

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
echo -e "${GREEN}Complete GitLab Setup${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Ensure port-forwards are running
echo -e "${BLUE}Step 1: Ensuring port-forwards are running...${NC}"
if ! lsof -i :8080 > /dev/null 2>&1; then
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /dev/null 2>&1 &
    sleep 3
    echo -e "${GREEN}✅ HTTP port-forward started${NC}"
else
    echo -e "${GREEN}✅ HTTP port-forward already running${NC}"
fi

if ! lsof -i :2222 > /dev/null 2>&1; then
    kubectl port-forward -n gitlab service/gitlab-service 2222:2222 > /dev/null 2>&1 &
    sleep 3
    echo -e "${GREEN}✅ SSH port-forward started${NC}"
else
    echo -e "${GREEN}✅ SSH port-forward already running${NC}"
fi
echo ""

# Add SSH key
echo -e "${BLUE}Step 2: Adding SSH key to GitLab...${NC}"
if [ -f ~/.ssh/id_ed25519.pub ]; then
    SSH_KEY=$(cat ~/.ssh/id_ed25519.pub)
    KEY_FILE=~/.ssh/id_ed25519.pub
elif [ -f ~/.ssh/id_rsa.pub ]; then
    SSH_KEY=$(cat ~/.ssh/id_rsa.pub)
    KEY_FILE=~/.ssh/id_rsa.pub
else
    echo -e "${RED}❌ No SSH key found${NC}"
    exit 1
fi

KEY_TITLE="$(hostname)-$(date +%Y%m%d)"
ADD_RESULT=$(curl -s -w "\nHTTP_CODE:%{http_code}" --request POST \
    --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    --header "Content-Type: application/json" \
    --data "{\"title\":\"${KEY_TITLE}\",\"key\":\"${SSH_KEY}\"}" \
    "${GITLAB_URL}/api/v4/user/keys" 2>&1)

HTTP_CODE=$(echo "$ADD_RESULT" | grep "HTTP_CODE" | cut -d: -f2)
if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ SSH key added successfully${NC}"
elif echo "$ADD_RESULT" | grep -q "has already been taken"; then
    echo -e "${YELLOW}⚠️  SSH key already exists${NC}"
else
    echo -e "${RED}❌ Failed to add SSH key (HTTP $HTTP_CODE)${NC}"
fi
echo ""

# Merge branches
echo -e "${BLUE}Step 3: Merging github-import-main branches into main...${NC}"
PROJECTS=(
    "infrastructure/core"
    "infrastructure/supabase"
    "microsoft-development/o365-forensics-investigator"
    "open-source-development/kali"
)

for PROJECT_PATH in "${PROJECTS[@]}"; do
    ENCODED_PATH="${PROJECT_PATH//\//%2F}"
    PROJ_ID=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "${GITLAB_URL}/api/v4/projects/${ENCODED_PATH}" | \
        python3 -c "import sys, json; print(json.load(sys.stdin).get('id', ''))" 2>/dev/null)
    
    if [ -n "$PROJ_ID" ] && [ "$PROJ_ID" != "None" ]; then
        # Unprotect branch
        curl -s --request DELETE \
            --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
            "${GITLAB_URL}/api/v4/projects/${PROJ_ID}/protected_branches/main" > /dev/null 2>&1
        
        sleep 1
        
        # Find or create MR
        MR_LIST=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
            "${GITLAB_URL}/api/v4/projects/${PROJ_ID}/merge_requests?source_branch=github-import-main&target_branch=main&state=opened")
        
        MR_IID=$(echo "$MR_LIST" | python3 -c "import sys, json; mr_list=json.load(sys.stdin); print(mr_list[0]['iid'] if mr_list and len(mr_list) > 0 else '')" 2>/dev/null)
        
        if [ -z "$MR_IID" ] || [ "$MR_IID" = "None" ]; then
            MR_CREATE=$(curl -s --request POST \
                --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
                --header "Content-Type: application/json" \
                --data '{"source_branch":"github-import-main","target_branch":"main","title":"Import from GitHub"}' \
                "${GITLAB_URL}/api/v4/projects/${PROJ_ID}/merge_requests" 2>&1)
            
            MR_IID=$(echo "$MR_CREATE" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('iid', '') or d.get('id', ''))" 2>/dev/null)
        fi
        
        if [ -n "$MR_IID" ] && [ "$MR_IID" != "None" ]; then
            sleep 1
            MERGE_RESULT=$(curl -s -w "\nHTTP_CODE:%{http_code}" --request PUT \
                --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
                --header "Content-Type: application/json" \
                --data '{"merge_commit_message":"Merge GitHub import into main"}' \
                "${GITLAB_URL}/api/v4/projects/${PROJ_ID}/merge_requests/${MR_IID}/merge" 2>&1)
            
            HTTP_CODE=$(echo "$MERGE_RESULT" | grep "HTTP_CODE" | cut -d: -f2)
            if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
                echo -e "${GREEN}  ✅ Merged ${PROJECT_PATH}${NC}"
            else
                echo -e "${YELLOW}  ⚠️  ${PROJECT_PATH} - Merge may need manual attention${NC}"
            fi
        fi
    fi
done
echo ""

# Final status
echo -e "${BLUE}Step 4: Final Status Check...${NC}"
echo ""
echo -e "${CYAN}SSH Keys in GitLab:${NC}"
curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    "${GITLAB_URL}/api/v4/user/keys" | \
    python3 -c "import sys, json; keys=json.load(sys.stdin); print(f'  {len(keys)} key(s) configured'); [print(f'    • {k.get(\"title\", \"N/A\")}') for k in keys[:3]]" 2>/dev/null || echo "  Could not retrieve keys"

echo ""
echo -e "${CYAN}Repository Status:${NC}"
for PROJECT_PATH in "${PROJECTS[@]}"; do
    ENCODED_PATH="${PROJECT_PATH//\//%2F}"
    PROJ_INFO=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "${GITLAB_URL}/api/v4/projects/${ENCODED_PATH}")
    
    COMMIT_COUNT=$(echo "$PROJ_INFO" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('statistics', {}).get('commit_count', 'N/A'))" 2>/dev/null || echo "N/A")
    echo "  ${PROJECT_PATH}: ${COMMIT_COUNT} commits"
done

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${CYAN}Access GitLab:${NC}"
echo "  Web UI: http://localhost:8080"
echo "  SSH: ssh://git@localhost:2222/GROUP/PROJECT.git"
echo ""



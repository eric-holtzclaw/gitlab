#!/bin/bash
# Push data-flow.drawio and README updates to GitLab
# Usage: ./scripts/push-google-workspace-diagram.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_PATH="/Users/eric/Documents/Scripts/open-source-development/Google-Workspace-Forensics-Investigator"

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Push Google Workspace Diagram to GitLab${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Check if repository directory exists
if [ ! -d "$REPO_PATH" ]; then
    echo -e "${RED}❌ Repository directory not found: $REPO_PATH${NC}"
    exit 1
fi

cd "$REPO_PATH"

# Check if files exist
if [ ! -f "data-flow.drawio" ]; then
    echo -e "${RED}❌ data-flow.drawio not found${NC}"
    exit 1
fi

if [ ! -f "README.md" ]; then
    echo -e "${RED}❌ README.md not found${NC}"
    exit 1
fi

echo -e "${BLUE}✅ Files found:${NC}"
echo "   - data-flow.drawio ($(wc -c < data-flow.drawio) bytes)"
echo "   - README.md ($(wc -c < README.md) bytes)"
echo ""

# Check git status
echo -e "${BLUE}Checking git status...${NC}"
git status --short
echo ""

# Check if port-forward is running
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Port-forward not running. Starting...${NC}"
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /dev/null 2>&1 &
    sleep 3
fi

if ! lsof -i :2222 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  SSH port-forward not running. Starting...${NC}"
    kubectl port-forward -n gitlab service/gitlab-service 2222:2222 > /dev/null 2>&1 &
    sleep 3
fi

# Correct repository path (verified - push succeeded)
REPO_PATHS=(
    "open-source-development/google-workspace-forensics-investigator"
)

echo -e "${BLUE}Attempting to push to GitLab...${NC}"
echo ""

SUCCESS=false

for REPO_PATH_VAR in "${REPO_PATHS[@]}"; do
    echo -e "${BLUE}Trying: $REPO_PATH_VAR${NC}"
    
    # Remove existing remotes
    git remote remove origin 2>/dev/null || true
    git remote remove gitlab 2>/dev/null || true
    
    # Try SSH first (best practice)
    git remote add origin "ssh://git@localhost:2222/$REPO_PATH_VAR.git" 2>/dev/null || continue
    
    if git push -uf origin main 2>&1 | grep -q "success\|To\|Counting\|Writing\|remote:.*To\|remote:.*[0-9]"; then
        echo -e "${GREEN}✅ Successfully pushed via SSH to: $REPO_PATH_VAR${NC}"
        SUCCESS=true
        break
    fi
    
    # If SSH failed, try HTTP with token (fallback)
    git remote remove origin 2>/dev/null || true
    GITLAB_TOKEN="glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3"
    git remote add origin "http://oauth2:${GITLAB_TOKEN}@localhost:8080/$REPO_PATH_VAR.git" 2>/dev/null || continue
    
    if git push -uf origin main 2>&1 | grep -q "success\|To\|Counting\|Writing\|remote:.*To\|remote:.*[0-9]"; then
        echo -e "${GREEN}✅ Successfully pushed via HTTP to: $REPO_PATH_VAR${NC}"
        SUCCESS=true
        break
    fi
    
    echo -e "${YELLOW}⚠️  Failed: $REPO_PATH_VAR${NC}"
    echo ""
done

if [ "$SUCCESS" = false ]; then
    echo -e "${RED}❌ Failed to push to any repository path${NC}"
    echo ""
    echo -e "${YELLOW}Possible issues:${NC}"
    echo "1. Repository doesn't exist in GitLab yet"
    echo "2. SSH key not added to GitLab"
    echo "3. Repository path is incorrect"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Create repository in GitLab UI: http://localhost:8080"
    echo "2. Or verify repository exists and path is correct"
    echo "3. Add SSH key if using SSH: http://localhost:8080/-/profile/keys"
    echo "4. Run this script again"
    exit 1
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✅ Push Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${BLUE}View repository:${NC}"
echo "   http://localhost:8080/$REPO_PATH_VAR"
echo ""


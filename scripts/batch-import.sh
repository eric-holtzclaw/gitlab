#!/bin/bash
# Batch Repository Import Script
# Imports all repositories from GitHub to GitLab using Personal Access Token
# Usage: ./scripts/batch-import.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Token (created via GitLab UI)
GITLAB_TOKEN="glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3"
GITLAB_URL="http://oauth2:${GITLAB_TOKEN}@localhost:8080"

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}GitLab Batch Repository Import${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Check port-forward
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Starting GitLab port-forward...${NC}"
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /dev/null 2>&1 &
    sleep 3
    echo -e "${GREEN}✅ Port-forward started${NC}"
    echo ""
fi

# Function to import a repository
import_repo() {
    local GITHUB_REPO=$1
    local GITLAB_GROUP=$2
    local REPO_NAME=$3
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Importing: ${REPO_NAME}${NC}"
    echo -e "${BLUE}  From: ${GITHUB_REPO}${NC}"
    echo -e "${BLUE}  To: ${GITLAB_GROUP}/${REPO_NAME}${NC}"
    echo ""
    
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Clone with mirror
    echo -e "${YELLOW}  Cloning from GitHub...${NC}"
    if ! git clone --mirror "$GITHUB_REPO" "${REPO_NAME}.git" 2>&1; then
        echo -e "${RED}  ❌ Failed to clone ${GITHUB_REPO}${NC}"
        echo -e "${RED}     Repository may be private or not exist.${NC}"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    cd "${REPO_NAME}.git"
    
    # Get commit count
    COMMIT_COUNT=$(git rev-list --all --count 2>/dev/null || echo "0")
    BRANCH_COUNT=$(git branch -r | wc -l | tr -d ' ')
    echo -e "${GREEN}  ✅ Cloned: ${COMMIT_COUNT} commits, ${BRANCH_COUNT} branches${NC}"
    
    # Push with force (overwrite existing content)
    echo -e "${YELLOW}  Pushing to GitLab...${NC}"
    GIT_TARGET="${GITLAB_URL}/${GITLAB_GROUP}/${REPO_NAME}.git"
    
    if git push --mirror --force "$GIT_TARGET" 2>&1 | tee /tmp/git-push-${REPO_NAME}.log; then
        echo -e "${GREEN}  ✅ Successfully imported ${REPO_NAME}${NC}"
        cd "$TEMP_DIR"
        rm -rf "${REPO_NAME}.git"
        rm -rf "$TEMP_DIR"
        echo ""
        return 0
    else
        echo -e "${RED}  ❌ Failed to push ${REPO_NAME}${NC}"
        echo -e "${RED}  Error details:${NC}"
        cat /tmp/git-push-${REPO_NAME}.log | tail -5 | sed 's/^/    /'
        cd "$TEMP_DIR"
        rm -rf "${REPO_NAME}.git"
        rm -rf "$TEMP_DIR"
        echo ""
        return 1
    fi
}

# Import all repositories
SUCCESS_COUNT=0
FAIL_COUNT=0

echo -e "${CYAN}Starting batch import...${NC}"
echo ""

# Infrastructure Group
echo -e "${BLUE}=== Infrastructure Group ===${NC}"
import_repo "https://github.com/eric-holtzclaw/core.git" "infrastructure" "core" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
import_repo "https://github.com/eric-holtzclaw/supabase.git" "infrastructure" "supabase" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
import_repo "https://github.com/eric-holtzclaw/Nginx.git" "infrastructure" "nginx" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
import_repo "https://github.com/eric-holtzclaw/gitlab.git" "infrastructure" "gitlab" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))

# Microsoft Development Group
echo -e "${BLUE}=== Microsoft Development Group ===${NC}"
import_repo "https://github.com/eric-holtzclaw/O365-Forensics-Investigator.git" "microsoft-development" "o365-forensics-investigator" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))

# Automation Group
echo -e "${BLUE}=== Automation Group ===${NC}"
import_repo "https://github.com/eric-holtzclaw/N8N.git" "automation" "n8n" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))

# Open Source Development Group
echo -e "${BLUE}=== Open Source Development Group ===${NC}"
import_repo "https://github.com/eric-holtzclaw/kali.git" "open-source-development" "kali" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))

# Summary
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Import Summary${NC}"
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✅ Success: ${SUCCESS_COUNT}${NC}"
if [ $FAIL_COUNT -gt 0 ]; then
    echo -e "${RED}❌ Failed: ${FAIL_COUNT}${NC}"
fi
echo ""
echo -e "${CYAN}View repositories at: http://localhost:8080${NC}"
echo ""


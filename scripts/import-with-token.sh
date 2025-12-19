#!/bin/bash
# Repository Import Script Using Personal Access Token
# Usage: GITLAB_TOKEN="your-token" ./scripts/import-with-token.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if token is provided
if [ -z "$GITLAB_TOKEN" ]; then
    echo -e "${RED}❌ Error: GITLAB_TOKEN environment variable not set${NC}"
    echo ""
    echo "Usage:"
    echo "  GITLAB_TOKEN=\"your-token\" ./scripts/import-with-token.sh"
    echo ""
    echo "To create a token:"
    echo "  1. Go to: http://localhost:8080/-/user_settings/personal_access_tokens"
    echo "  2. Create token with scopes: api, write_repository, read_repository"
    echo "  3. Copy token and set: export GITLAB_TOKEN=\"your-token\""
    exit 1
fi

GITLAB_URL="http://oauth2:${GITLAB_TOKEN}@localhost:8080"

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}GitLab Repository Import${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Function to import a repository
import_repo() {
    local GITHUB_REPO=$1
    local GITLAB_GROUP=$2
    local REPO_NAME=$3
    
    echo -e "${BLUE}Importing: ${REPO_NAME}${NC}"
    echo "  From: ${GITHUB_REPO}"
    echo "  To: ${GITLAB_URL}/${GITLAB_GROUP}/${REPO_NAME}.git"
    
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Clone
    if ! git clone --mirror "$GITHUB_REPO" "${REPO_NAME}.git" 2>&1 | tee /tmp/git-clone-${REPO_NAME}.log; then
        echo -e "${RED}❌ Failed to clone ${GITHUB_REPO}${NC}"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    cd "${REPO_NAME}.git"
    
    # Push with force (overwrite existing content)
    if git push --mirror --force "${GITLAB_URL}/${GITLAB_GROUP}/${REPO_NAME}.git" 2>&1 | tee /tmp/git-push-${REPO_NAME}.log; then
        echo -e "${GREEN}✅ Successfully imported ${REPO_NAME}${NC}"
        cd "$TEMP_DIR"
        rm -rf "${REPO_NAME}.git"
        rm -rf "$TEMP_DIR"
        echo ""
        return 0
    else
        echo -e "${RED}❌ Failed to push ${REPO_NAME}${NC}"
        echo "Error details:"
        cat /tmp/git-push-${REPO_NAME}.log | tail -5
        cd "$TEMP_DIR"
        rm -rf "${REPO_NAME}.git"
        rm -rf "$TEMP_DIR"
        echo ""
        return 1
    fi
}

# Check port-forward
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Starting GitLab port-forward...${NC}"
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /dev/null 2>&1 &
    sleep 3
fi

echo -e "${CYAN}Starting repository imports...${NC}"
echo ""

# Infrastructure Group
echo -e "${BLUE}=== Infrastructure Group ===${NC}"
import_repo "https://github.com/eric-holtzclaw/core.git" "infrastructure" "core"
import_repo "https://github.com/eric-holtzclaw/supabase.git" "infrastructure" "supabase"
import_repo "https://github.com/eric-holtzclaw/Nginx.git" "infrastructure" "nginx"
import_repo "https://github.com/eric-holtzclaw/gitlab.git" "infrastructure" "gitlab"

# Microsoft Development Group
echo -e "${BLUE}=== Microsoft Development Group ===${NC}"
import_repo "https://github.com/eric-holtzclaw/O365-Forensics-Investigator.git" "microsoft-development" "o365-forensics-investigator"
# Note: Google-Workspace-Forensics-Investigator is in wrong group - fix later

# Automation Group
echo -e "${BLUE}=== Automation Group ===${NC}"
import_repo "https://github.com/eric-holtzclaw/N8N.git" "automation" "n8n"

# Open Source Development Group
echo -e "${BLUE}=== Open Source Development Group ===${NC}"
import_repo "https://github.com/eric-holtzclaw/kali.git" "open-source-development" "kali"

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Import Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Verify imports at: http://localhost:8080"


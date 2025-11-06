#!/bin/bash
# Complete Repository Import Script
# Tries Option B (direct push) first, falls back to manual creation if needed
# Usage: ./scripts/import-all-repos.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

GITLAB_URL="http://localhost:8080"
GITLAB_USER="root"
GITLAB_PASS="ChangeMe123!@#SecurePassword"

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Complete GitLab Repository Import${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Function to import a repository
import_repo() {
    local GITHUB_URL=$1
    local GITLAB_GROUP=$2
    local REPO_NAME=$3
    
    echo -e "${BLUE}Importing: ${REPO_NAME}${NC}"
    echo "  From: ${GITHUB_URL}"
    echo "  To: ${GITLAB_URL}/${GITLAB_GROUP}/${REPO_NAME}.git"
    echo ""
    
    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Clone with mirror
    if ! git clone --mirror "$GITHUB_URL" "$REPO_NAME.git" 2>/dev/null; then
        echo -e "${RED}❌ Failed to clone ${GITHUB_URL}${NC}"
        echo "   Repository may be private or not exist."
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    cd "$REPO_NAME.git"
    
    # Try to push (will work if project exists, or if GitLab auto-creates)
    GIT_URL="http://${GITLAB_USER}:${GITLAB_PASS}@localhost:8080/${GITLAB_GROUP}/${REPO_NAME}.git"
    
    if git push --mirror "$GIT_URL" 2>&1 | tee /tmp/git-push-output.log | grep -qE "(remote:.*repository.*not found|remote:.*Project not found)"; then
        echo -e "${YELLOW}⚠️  Project doesn't exist. Creating it first...${NC}"
        echo "   Go to: ${GITLAB_URL}/${GITLAB_GROUP}"
        echo "   Click 'New project' → 'Create blank project'"
        echo "   Name: ${REPO_NAME}"
        echo "   Uncheck 'Initialize repository with README'"
        echo "   Then run this script again."
        cd "$TEMP_DIR"
        rm -rf "$REPO_NAME.git"
        rm -rf "$TEMP_DIR"
        return 1
    elif git push --mirror "$GIT_URL" 2>&1 | tee /tmp/git-push-output.log | grep -qE "(error|fatal)"; then
        echo -e "${RED}❌ Failed to push ${REPO_NAME}${NC}"
        cat /tmp/git-push-output.log | tail -5
        cd "$TEMP_DIR"
        rm -rf "$REPO_NAME.git"
        rm -rf "$TEMP_DIR"
        return 1
    else
        echo -e "${GREEN}✅ Successfully imported ${REPO_NAME}${NC}"
        cd "$TEMP_DIR"
        rm -rf "$REPO_NAME.git"
        rm -rf "$TEMP_DIR"
        echo ""
        return 0
    fi
}

# Check if port-forward is running
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  GitLab port-forward not running. Starting it...${NC}"
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /dev/null 2>&1 &
    sleep 3
fi

echo -e "${CYAN}Starting repository imports...${NC}"
echo ""

# Infrastructure Group
echo -e "${BLUE}=== Infrastructure Group ===${NC}"
# core already exists, skip it
import_repo "https://github.com/eric-holtzclaw/supabase.git" "infrastructure" "supabase"
import_repo "https://github.com/eric-holtzclaw/Nginx.git" "infrastructure" "nginx"
import_repo "https://github.com/eric-holtzclaw/gitlab.git" "infrastructure" "gitlab"

# Microsoft Development Group
echo -e "${BLUE}=== Microsoft Development Group ===${NC}"
import_repo "https://github.com/eric-holtzclaw/O365-Forensics-Investigator.git" "microsoft-development" "O365-Forensics-Investigator"
import_repo "https://github.com/eric-holtzclaw/Google-Workspace-Forensics-Investigator.git" "microsoft-development" "Google-Workspace-Forensics-Investigator"

# Automation Group
echo -e "${BLUE}=== Automation Group ===${NC}"
import_repo "https://github.com/eric-holtzclaw/N8N.git" "automation" "N8N"

# Open Source Development Group
echo -e "${BLUE}=== Open Source Development Group ===${NC}"
import_repo "https://github.com/eric-holtzclaw/kali.git" "open-source-development" "kali"

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Import Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${CYAN}Next Steps:${NC}"
echo "1. Verify all repositories in GitLab UI"
echo "2. For 'core' project, push the code:"
echo "   cd /tmp && git clone --mirror https://github.com/eric-holtzclaw/core.git core.git"
echo "   cd core.git && git push --mirror http://root:ChangeMe123!@#SecurePassword@localhost:8080/infrastructure/core.git"
echo "3. Set up mirroring for core, supabase, nginx (NOT gmaxgolfapp)"
echo "   - Go to project → Settings → Repository → Mirroring repositories"
echo ""



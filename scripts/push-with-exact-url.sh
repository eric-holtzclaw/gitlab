#!/bin/bash
# Push using exact clone URL from GitLab UI
# Usage: ./scripts/push-with-exact-url.sh "ssh://git@localhost:2222/open-source-development/repo-name.git"

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo -e "${RED}Usage: $0 <git-clone-url>${NC}"
    echo ""
    echo "Example:"
    echo "  $0 \"ssh://git@localhost:2222/open-source-development/google-workspace-forensics-investigator.git\""
    echo ""
    echo "To get the exact URL:"
    echo "1. Go to repository in GitLab UI"
    echo "2. Click 'Clone' button"
    echo "3. Copy the SSH URL"
    exit 1
fi

CLONE_URL="$1"
REPO_PATH="/Users/ericholtzclaw/Scripts/browser/Google-Workspace-Forensics-Investigator"

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Push Using Exact Clone URL${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

cd "$REPO_PATH"

echo -e "${BLUE}Using clone URL:${NC} $CLONE_URL"
echo ""

# Check if port-forwards are running
if ! lsof -i :2222 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  SSH port-forward not running. Starting...${NC}"
    kubectl port-forward -n gitlab service/gitlab-service 2222:2222 > /dev/null 2>&1 &
    sleep 3
fi

# Remove existing remotes
git remote remove origin 2>/dev/null || true
git remote remove gitlab 2>/dev/null || true

# Add remote with exact URL
echo -e "${BLUE}Setting up remote...${NC}"
git remote add origin "$CLONE_URL"

echo -e "${BLUE}Pushing to GitLab...${NC}"
if git push -uf origin main 2>&1; then
    echo ""
    echo -e "${GREEN}✅ Successfully pushed!${NC}"
    echo ""
    # Extract repository path from URL for display
    REPO_DISPLAY=$(echo "$CLONE_URL" | sed 's|ssh://git@localhost:2222/||' | sed 's|\.git$||')
    echo -e "${BLUE}View repository:${NC}"
    echo "   http://localhost:8080/$REPO_DISPLAY"
else
    echo ""
    echo -e "${RED}❌ Push failed${NC}"
    echo ""
    echo -e "${YELLOW}Possible issues:${NC}"
    echo "1. SSH key not added to GitLab"
    echo "2. Repository path incorrect"
    echo "3. Branch protection enabled"
    echo ""
    echo "Check SSH key: http://localhost:8080/-/profile/keys"
    exit 1
fi


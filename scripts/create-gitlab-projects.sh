#!/bin/bash
# GitLab Project Creation Script
# Creates projects in GitLab based on repository structure
# Usage: ./scripts/create-gitlab-projects.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

GITLAB_URL="http://localhost:8080"
GITLAB_USER="root"
GITLAB_TOKEN=""  # Will prompt if not set

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}GitLab Project Creation${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Check if port-forward is running
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  GitLab port-forward not running${NC}"
    echo "Starting port-forward..."
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /dev/null 2>&1 &
    sleep 3
    echo -e "${GREEN}✅ Port-forward started${NC}"
fi

# Check GitLab API access
echo -e "${BLUE}Checking GitLab API access...${NC}"
if ! curl -s "${GITLAB_URL}/api/v4/user" > /dev/null 2>&1; then
    echo -e "${RED}❌ Cannot access GitLab API${NC}"
    echo "Make sure GitLab is accessible at ${GITLAB_URL}"
    exit 1
fi

echo ""
echo -e "${GREEN}GitLab Projects to Create:${NC}"
echo ""
echo "=== HIGH PRIORITY ==="
echo "1. core (Import from GitHub)"
echo "2. gmaxgolfapp (Import from GitHub)"
echo "3. supabase (Import from GitHub)"
echo "4. nginx (Create new)"
echo ""
echo "=== MEDIUM PRIORITY ==="
echo "5. N8N (Import from GitHub)"
echo "6. kali (Import from GitHub)"
echo "7. O365-Forensics-Investigator (Import from GitHub)"
echo "8. Google-Workspace-Forensics-Investigator (Import from GitHub)"
echo ""
echo "=== LATER ==="
echo "9. gitlab (Import from GitHub - self-tracking)"
echo "10. muse (Create new)"
echo "11. home-assistant (Create new)"
echo "12. workspace-token-monitor (Create new)"
echo ""
echo -e "${YELLOW}Note: This script provides instructions.${NC}"
echo -e "${YELLOW}For security, create projects manually in GitLab UI.${NC}"
echo ""
echo "See GITLAB_PROJECT_STRUCTURE.md for detailed instructions."




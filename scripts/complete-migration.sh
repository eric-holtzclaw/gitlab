#!/bin/bash
# Complete GitLab Migration Script
# Automates group creation and repository imports via GitLab API
# Usage: ./scripts/complete-migration.sh

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
GITLAB_PASSWORD="ChangeMe123!@#SecurePassword"

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Complete GitLab Migration${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Check if port-forward is running
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Starting GitLab port-forward...${NC}"
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /dev/null 2>&1 &
    sleep 3
fi

# Get GitLab personal access token (or create one)
echo -e "${BLUE}Getting GitLab authentication token...${NC}"
echo ""
echo -e "${YELLOW}Note: This script will guide you through:${NC}"
echo "  1. Creating remaining groups"
echo "  2. Importing repositories from GitHub"
echo "  3. Setting up mirroring (manual step)"
echo ""
echo -e "${CYAN}For full automation, you'll need to:${NC}"
echo "  1. Create a GitLab personal access token"
echo "  2. Or use the GitLab UI for repository imports"
echo ""
echo -e "${GREEN}Migration steps:${NC}"
echo ""
echo "=== Step 1: Create Remaining Groups ==="
echo ""
echo "Remaining groups to create:"
echo "  - Applications"
echo "  - Forensics"
echo "  - Automation"
echo "  - Development"
echo ""
echo "To create in GitLab UI:"
echo "  1. Go to: ${GITLAB_URL}/groups/new"
echo "  2. Create each group with Private visibility"
echo ""
echo "=== Step 2: Import Repositories ==="
echo ""
echo "For each repository, go to the appropriate group and:"
echo "  1. Click 'New project' → 'Import project'"
echo "  2. Select 'Repository by URL'"
echo "  3. Enter GitHub URL"
echo ""
echo "Repository import list:"
echo ""
echo -e "${BLUE}Infrastructure Group:${NC}"
echo "  • core: https://github.com/eric-holtzclaw/core.git"
echo "  • supabase: https://github.com/eric-holtzclaw/supabase.git"
echo "  • nginx: https://github.com/eric-holtzclaw/Nginx.git"
echo ""
echo -e "${BLUE}Applications Group:${NC}"
echo "  • gmaxgolfapp: https://github.com/eric-holtzclaw/gmaxgolfapp.git"
echo ""
echo -e "${BLUE}Forensics Group:${NC}"
echo "  • O365-Forensics-Investigator: https://github.com/eric-holtzclaw/O365-Forensics-Investigator.git"
echo "  • Google-Workspace-Forensics-Investigator: https://github.com/eric-holtzclaw/Google-Workspace-Forensics-Investigator.git"
echo ""
echo -e "${BLUE}Automation Group:${NC}"
echo "  • N8N: https://github.com/eric-holtzclaw/N8N.git"
echo ""
echo -e "${BLUE}Development Group:${NC}"
echo "  • kali: https://github.com/eric-holtzclaw/kali.git"
echo ""
echo -e "${BLUE}Infrastructure Group (additional):${NC}"
echo "  • gitlab: https://github.com/eric-holtzclaw/gitlab.git"
echo ""
echo "=== Step 3: Set Up Mirroring ==="
echo ""
echo "For mirrored repositories (core, gmaxgolfapp, supabase, nginx):"
echo "  1. Go to project → Settings → Repository → Mirroring repositories"
echo "  2. Configure push mirror to GitHub"
echo "  3. Use GitHub personal access token"
echo ""
echo -e "${GREEN}✅ Migration guide complete!${NC}"
echo ""
echo "See MIGRATION_PLAN.md for detailed instructions."
echo ""
echo -e "${CYAN}Quick access:${NC}"
echo "  GitLab: ${GITLAB_URL}"
echo "  Login: ${GITLAB_USER} / ${GITLAB_PASSWORD}"
echo ""




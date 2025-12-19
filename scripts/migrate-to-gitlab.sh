#!/bin/bash
# GitLab Migration Helper Script
# Helps with importing repositories and setting up mirroring
# Usage: ./scripts/migrate-to-gitlab.sh

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

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}GitLab Migration Helper${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Check if port-forward is running
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  GitLab port-forward not running${NC}"
    echo "Starting port-forward..."
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /dev/null 2>&1 &
    sleep 3
    echo -e "${GREEN}✅ Port-forward started${NC}"
    echo ""
fi

# Check GitLab access
echo -e "${BLUE}Checking GitLab access...${NC}"
if ! curl -s "${GITLAB_URL}" > /dev/null 2>&1; then
    echo -e "${RED}❌ Cannot access GitLab at ${GITLAB_URL}${NC}"
    echo "Please ensure GitLab is running and port-forward is active."
    exit 1
fi
echo -e "${GREEN}✅ GitLab is accessible${NC}"
echo ""

# Display menu
echo -e "${CYAN}GitLab Migration Helper${NC}"
echo ""
echo "1. Show migration checklist"
echo "2. Generate import commands"
echo "3. Generate mirroring setup guide"
echo "4. Update local git remotes"
echo "5. Show all GitHub repositories"
echo "6. Exit"
echo ""
read -p "Select option (1-6): " choice

case $choice in
    1)
        echo ""
        echo -e "${GREEN}=== Migration Checklist ===${NC}"
        echo ""
        echo -e "${BLUE}Phase 1: Import Critical Repos${NC}"
        echo "  [ ] Create GitLab groups"
        echo "  [ ] Import core"
        echo "  [ ] Import gmaxgolfapp"
        echo "  [ ] Import supabase"
        echo "  [ ] Import nginx"
        echo ""
        echo -e "${BLUE}Phase 2: Set Up Mirroring${NC}"
        echo "  [ ] Create GitHub personal access token"
        echo "  [ ] Configure mirroring for core"
        echo "  [ ] Configure mirroring for gmaxgolfapp"
        echo "  [ ] Configure mirroring for supabase"
        echo "  [ ] Configure mirroring for nginx"
        echo ""
        echo -e "${BLUE}Phase 3: Import Remaining Repos${NC}"
        echo "  [ ] Import O365-Forensics-Investigator"
        echo "  [ ] Import Google-Workspace-Forensics-Investigator"
        echo "  [ ] Import N8N"
        echo "  [ ] Import kali"
        echo "  [ ] Import gitlab"
        echo ""
        echo "See MIGRATION_PLAN.md for detailed instructions."
        ;;
    2)
        echo ""
        echo -e "${GREEN}=== Import Commands ===${NC}"
        echo ""
        echo -e "${BLUE}Critical Repos (Phase 1):${NC}"
        echo ""
        echo "1. core:"
        echo "   Group: Infrastructure"
        echo "   URL: https://github.com/eric-holtzclaw/core.git"
        echo ""
        echo "2. gmaxgolfapp:"
        echo "   Group: Applications"
        echo "   URL: https://github.com/eric-holtzclaw/gmaxgolfapp.git"
        echo ""
        echo "3. supabase:"
        echo "   Group: Infrastructure"
        echo "   URL: https://github.com/eric-holtzclaw/supabase.git"
        echo ""
        echo "4. nginx:"
        echo "   Group: Infrastructure"
        echo "   URL: https://github.com/eric-holtzclaw/Nginx.git"
        echo ""
        echo -e "${BLUE}Remaining Repos (Phase 3):${NC}"
        echo ""
        echo "5. O365-Forensics-Investigator:"
        echo "   Group: Forensics"
        echo "   URL: https://github.com/eric-holtzclaw/O365-Forensics-Investigator.git"
        echo ""
        echo "6. Google-Workspace-Forensics-Investigator:"
        echo "   Group: Forensics"
        echo "   URL: https://github.com/eric-holtzclaw/Google-Workspace-Forensics-Investigator.git"
        echo ""
        echo "7. N8N:"
        echo "   Group: Automation"
        echo "   URL: https://github.com/eric-holtzclaw/N8N.git"
        echo ""
        echo "8. kali:"
        echo "   Group: Development"
        echo "   URL: https://github.com/eric-holtzclaw/kali.git"
        echo ""
        echo "9. gitlab:"
        echo "   Group: Infrastructure"
        echo "   URL: https://github.com/eric-holtzclaw/gitlab.git"
        echo ""
        echo -e "${YELLOW}To import:${NC}"
        echo "1. Go to ${GITLAB_URL}"
        echo "2. Navigate to the appropriate group"
        echo "3. Click 'New Project' → 'Import project'"
        echo "4. Select 'Repository by URL'"
        echo "5. Enter the GitHub URL above"
        echo "6. Click 'Create project'"
        ;;
    3)
        echo ""
        echo -e "${GREEN}=== Mirroring Setup Guide ===${NC}"
        echo ""
        echo -e "${BLUE}Step 1: Create GitHub Personal Access Token${NC}"
        echo "1. Go to: https://github.com/settings/tokens"
        echo "2. Click 'Generate new token (classic)'"
        echo "3. Name: 'GitLab Mirroring'"
        echo "4. Select scopes:"
        echo "   - repo (Full control)"
        echo "   - workflow (Optional, for GitHub Actions)"
        echo "5. Click 'Generate token'"
        echo "6. Copy the token (you won't see it again!)"
        echo ""
        echo -e "${BLUE}Step 2: Configure Mirroring in GitLab${NC}"
        echo ""
        echo "For each mirrored repository (core, gmaxgolfapp, supabase, nginx):"
        echo "1. Go to project in GitLab"
        echo "2. Settings → Repository → Mirroring repositories"
        echo "3. Expand 'Push mirror'"
        echo "4. Git repository URL: https://github.com/eric-holtzclaw/REPO_NAME.git"
        echo "5. Mirror direction: Push"
        echo "6. Authentication method: Password"
        echo "7. Password: [Your GitHub token]"
        echo "8. Keep divergent refs: Unchecked"
        echo "9. Click 'Mirror repository'"
        echo ""
        echo -e "${YELLOW}Mirrored Repositories:${NC}"
        echo "  - core → https://github.com/eric-holtzclaw/core.git"
        echo "  - gmaxgolfapp → https://github.com/eric-holtzclaw/gmaxgolfapp.git"
        echo "  - supabase → https://github.com/eric-holtzclaw/supabase.git"
        echo "  - nginx → https://github.com/eric-holtzclaw/Nginx.git"
        ;;
    4)
        echo ""
        echo -e "${GREEN}=== Update Local Git Remotes ===${NC}"
        echo ""
        echo -e "${BLUE}For mirrored repositories (core, gmaxgolfapp, supabase, nginx):${NC}"
        echo ""
        echo "After importing to GitLab, update your local remotes:"
        echo ""
        echo "For core:"
        echo "  cd /path/to/core"
        echo "  git remote set-url origin git@localhost:2222:Infrastructure/core.git"
        echo ""
        echo "For gmaxgolfapp:"
        echo "  cd /path/to/gmaxgolfapp"
        echo "  git remote set-url origin git@localhost:2222:Applications/gmaxgolfapp.git"
        echo ""
        echo "For supabase:"
        echo "  cd /path/to/supabase"
        echo "  git remote set-url origin git@localhost:2222:Infrastructure/supabase.git"
        echo ""
        echo "For nginx:"
        echo "  cd /path/to/nginx"
        echo "  git remote set-url origin git@localhost:2222:Infrastructure/nginx.git"
        echo ""
        echo -e "${YELLOW}Note:${NC} Replace 'localhost:2222' with your actual GitLab SSH URL"
        echo "You can find it in GitLab project → Clone → SSH"
        ;;
    5)
        echo ""
        echo -e "${GREEN}=== All GitHub Repositories ===${NC}"
        echo ""
        echo "Critical (Mirror):"
        echo "  1. https://github.com/eric-holtzclaw/core.git"
        echo "  2. https://github.com/eric-holtzclaw/gmaxgolfapp.git"
        echo "  3. https://github.com/eric-holtzclaw/supabase.git"
        echo "  4. https://github.com/eric-holtzclaw/Nginx.git"
        echo ""
        echo "Other (Import Only):"
        echo "  5. https://github.com/eric-holtzclaw/O365-Forensics-Investigator.git"
        echo "  6. https://github.com/eric-holtzclaw/Google-Workspace-Forensics-Investigator.git"
        echo "  7. https://github.com/eric-holtzclaw/N8N.git"
        echo "  8. https://github.com/eric-holtzclaw/kali.git"
        echo "  9. https://github.com/eric-holtzclaw/gitlab.git"
        echo ""
        echo "Total: 9 repositories"
        ;;
    6)
        echo ""
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Done!${NC}"
echo ""
echo "For detailed instructions, see: MIGRATION_PLAN.md"




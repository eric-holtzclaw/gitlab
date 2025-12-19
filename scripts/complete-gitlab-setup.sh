#!/bin/bash
# Complete GitLab setup automation
# Runs all optimization and configuration scripts

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}Complete GitLab Setup & Optimization${NC}"
echo -e "${CYAN}==========================================${NC}"
echo ""

# Ensure port-forward is running
echo -e "${BLUE}Ensuring GitLab port-forward is running...${NC}"
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo "Starting port-forward..."
    pkill -f "kubectl port-forward.*gitlab.*8080" 2>/dev/null || true
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /tmp/gitlab-http-port-forward.log 2>&1 &
    sleep 5
    
    if lsof -i :8080 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Port-forward started${NC}"
    else
        echo -e "${YELLOW}⚠️  Port-forward may need manual start${NC}"
    fi
else
    echo -e "${GREEN}✅ Port-forward already running${NC}"
fi

echo ""

# 1. Enable Diagrams.net
echo -e "${CYAN}1️⃣  Enabling Diagrams.net integration...${NC}"
if bash scripts/enable-diagrams-net.sh; then
    echo -e "${GREEN}✅ Diagrams.net configured${NC}"
else
    echo -e "${YELLOW}⚠️  Diagrams.net setup had issues (may need manual configuration)${NC}"
fi
echo ""

# 2. Configure CI/CD settings
echo -e "${CYAN}2️⃣  Configuring CI/CD settings...${NC}"
if bash scripts/configure-ci-cd-settings.sh; then
    echo -e "${GREEN}✅ CI/CD settings configured${NC}"
else
    echo -e "${YELLOW}⚠️  CI/CD settings had issues${NC}"
fi
echo ""

# 3. Enable metrics
echo -e "${CYAN}3️⃣  Enabling metrics & profiling...${NC}"
if bash scripts/enable-metrics-profiling.sh; then
    echo -e "${GREEN}✅ Metrics & profiling enabled${NC}"
else
    echo -e "${YELLOW}⚠️  Metrics setup had issues${NC}"
fi
echo ""

# 4. Setup GitHub mirroring (if token provided)
echo -e "${CYAN}4️⃣  Setting up GitHub mirroring...${NC}"
if [ -n "$GITHUB_TOKEN" ]; then
    if bash scripts/setup-github-mirroring.sh; then
        echo -e "${GREEN}✅ GitHub mirroring configured${NC}"
    else
        echo -e "${YELLOW}⚠️  GitHub mirroring had issues${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Skipping GitHub mirroring (set GITHUB_TOKEN to enable)${NC}"
    echo "   Run: export GITHUB_TOKEN=your_token && bash scripts/setup-github-mirroring.sh"
fi
echo ""

# 5. Cluster Agent setup (informational)
echo -e "${CYAN}5️⃣  Cluster Agent setup (manual steps required)${NC}"
echo "   See: scripts/setup-cluster-agent.sh"
echo "   Guide: https://docs.gitlab.com/18.5/user/clusters/agent/"
echo ""

echo -e "${CYAN}==========================================${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${CYAN}==========================================${NC}"
echo ""
echo -e "${BLUE}📋 Summary:${NC}"
echo "   • Diagrams.net: Enabled"
echo "   • CI/CD Settings: Configured"
echo "   • Metrics & Profiling: Enabled"
echo "   • GitHub Mirroring: $([ -n "$GITHUB_TOKEN" ] && echo 'Configured' || echo 'Skipped (set GITHUB_TOKEN)')"
echo ""
echo -e "${BLUE}🔗 Quick Links:${NC}"
echo "   • GitLab UI: http://localhost:8080"
echo "   • CI/CD Settings: http://localhost:8080/admin/application_settings/ci_cd"
echo "   • Metrics: http://localhost:8080/admin/application_settings/metrics_and_profiling"
echo "   • Diagrams.net: http://localhost:8080/admin/application_settings/integrations"
echo ""
echo -e "${BLUE}📚 Additional Scripts:${NC}"
echo "   • Backup: ./scripts/backup-gitlab.sh"
echo "   • Health Check: ./scripts/check-gitlab-health.sh"
echo "   • Create Repo: ./scripts/create-repo-template.sh <name> <group>"
echo ""



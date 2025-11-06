#!/bin/bash
# Enable Diagrams.net integration in GitLab
# See: https://docs.gitlab.com/18.5/administration/integration/diagrams_net/

set -e

GITLAB_URL="http://localhost:8080"
GITLAB_TOKEN="glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Enabling Diagrams.net Integration ===${NC}"

# Check if port-forward is running
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo "⚠️  GitLab port-forward not running. Starting it..."
    pkill -f "kubectl port-forward.*gitlab.*8080" 2>/dev/null || true
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /tmp/gitlab-http-port-forward.log 2>&1 &
    sleep 3
fi

# Enable Diagrams.net via Admin API
RESULT=$(curl -s --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "diagramsnet_enabled": true,
    "diagramsnet_url": "https://www.diagrams.net"
  }' \
  "${GITLAB_URL}/api/v4/application/settings" 2>&1)

if echo "$RESULT" | grep -q '"diagramsnet_enabled":true'; then
    echo -e "${GREEN}✅ Diagrams.net enabled successfully!${NC}"
else
    # Check if it's already enabled or if there's an error
    if echo "$RESULT" | grep -q "diagramsnet_enabled"; then
        echo -e "${GREEN}✅ Diagrams.net already enabled${NC}"
    else
        echo "⚠️  Response: $RESULT" | head -5
        echo "   Note: This feature may require GitLab 13.5+"
    fi
fi

echo ""
echo -e "${BLUE}📝 Usage in repositories:${NC}"
echo "1. Create/edit .drawio or .drawio.svg files in any repository"
echo "2. Click 'Edit' in GitLab UI to open Diagrams.net editor"
echo "3. Create architecture diagrams, flowcharts, etc."
echo ""
echo "Example files to create:"
echo "  - docs/architecture.drawio"
echo "  - docs/deployment-flow.drawio.svg"
echo "  - README-diagram.drawio"
echo ""
echo "🌐 Verify in GitLab Admin:"
echo "   http://localhost:8080/admin/application_settings/integrations"



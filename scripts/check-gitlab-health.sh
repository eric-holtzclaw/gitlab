#!/bin/bash
# Monitor GitLab health and performance

set -e

GITLAB_URL="http://localhost:8080"
GITLAB_TOKEN="glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== GitLab Health Check ===${NC}"
echo ""

# Check if port-forward is running
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  GitLab port-forward not running${NC}"
    echo "   Starting port-forward..."
    pkill -f "kubectl port-forward.*gitlab.*8080" 2>/dev/null || true
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /tmp/gitlab-http-port-forward.log 2>&1 &
    sleep 3
fi

echo -e "${BLUE}1. API Health Check${NC}"
API_VERSION=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    "${GITLAB_URL}/api/v4/version" 2>/dev/null | \
    python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('version', 'Unknown'))" 2>/dev/null || echo "Unknown")

if [ "$API_VERSION" != "Unknown" ]; then
    echo -e "${GREEN}   ✅ GitLab Version: ${API_VERSION}${NC}"
else
    echo -e "${RED}   ❌ API not responding${NC}"
fi

echo ""

echo -e "${BLUE}2. System Status${NC}"
SYSTEM_STATUS=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    "${GITLAB_URL}/api/v4/system/status" 2>/dev/null)

if echo "$SYSTEM_STATUS" | grep -q '"status"'; then
    STATUS=$(echo "$SYSTEM_STATUS" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('status', 'unknown'))" 2>/dev/null)
    echo -e "${GREEN}   ✅ System Status: ${STATUS}${NC}"
    
    # Show additional info
    if echo "$SYSTEM_STATUS" | grep -q '"queues"'; then
        QUEUES=$(echo "$SYSTEM_STATUS" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('queues', {}).get('default', 0))" 2>/dev/null)
        echo "   Queues: ${QUEUES}"
    fi
else
    echo -e "${YELLOW}   ⚠️  Could not retrieve system status${NC}"
fi

echo ""

echo -e "${BLUE}3. Kubernetes Pod Status${NC}"
POD_STATUS=$(kubectl get pods -n gitlab -l app=gitlab -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "Unknown")
POD_NAME=$(kubectl get pods -n gitlab -l app=gitlab -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "Unknown")

if [ "$POD_STATUS" = "Running" ]; then
    echo -e "${GREEN}   ✅ Pod Status: ${POD_STATUS}${NC}"
    echo "   Pod: $POD_NAME"
else
    echo -e "${YELLOW}   ⚠️  Pod Status: ${POD_STATUS}${NC}"
fi

echo ""

echo -e "${BLUE}4. Resource Usage${NC}"
if kubectl top pod -n gitlab -l app=gitlab 2>/dev/null | grep -q "NAME"; then
    kubectl top pod -n gitlab -l app=gitlab 2>/dev/null | tail -n +2 | while read -r line; do
        echo "   $line"
    done
else
    echo -e "${YELLOW}   ⚠️  Metrics server not available${NC}"
fi

echo ""

echo -e "${BLUE}5. Storage Usage${NC}"
PVC_STATUS=$(kubectl get pvc -n gitlab -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "Unknown")
if [ "$PVC_STATUS" = "Bound" ]; then
    echo -e "${GREEN}   ✅ PVC Status: ${PVC_STATUS}${NC}"
    
    # Get storage capacity and usage if available
    CAPACITY=$(kubectl get pvc -n gitlab -o jsonpath='{.items[0].status.capacity.storage}' 2>/dev/null || echo "Unknown")
    echo "   Capacity: $CAPACITY"
else
    echo -e "${YELLOW}   ⚠️  PVC Status: ${PVC_STATUS}${NC}"
fi

echo ""

echo -e "${BLUE}=== Health Check Complete ===${NC}"
echo ""
echo "For detailed logs:"
echo "  kubectl logs -n gitlab deployment/gitlab -f"
echo ""
echo "For pod events:"
echo "  kubectl describe pod -n gitlab -l app=gitlab"



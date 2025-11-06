#!/bin/bash
# Check GitLab Status and Setup Port-Forward
# Usage: ./scripts/check-gitlab-status.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Checking GitLab Status...${NC}"
echo ""

# Check pod status
POD_STATUS=$(kubectl get pods -n gitlab -l app=gitlab -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NotFound")
READY=$(kubectl get pods -n gitlab -l app=gitlab -o jsonpath='{.items[0].status.containerStatuses[0].ready}' 2>/dev/null || echo "false")

if [ "$POD_STATUS" == "NotFound" ]; then
    echo -e "${RED}❌ GitLab pod not found${NC}"
    exit 1
fi

echo "Pod Status: $POD_STATUS"
echo "Ready: $READY"
echo ""

if [ "$POD_STATUS" == "Pending" ] || [ "$POD_STATUS" == "PodInitializing" ]; then
    echo -e "${YELLOW}⚠️  GitLab is still starting...${NC}"
    echo ""
    echo "This can take 5-10 minutes because:"
    echo "  1. GitLab image is large (~2GB)"
    echo "  2. GitLab needs to initialize database"
    echo "  3. GitLab needs to configure services"
    echo ""
    echo "Checking pod details:"
    kubectl get pods -n gitlab -l app=gitlab
    echo ""
    echo "To monitor progress:"
    echo "  kubectl get pods -n gitlab -w"
    echo "  kubectl logs -n gitlab -l app=gitlab -f"
    exit 0
fi

if [ "$READY" == "true" ]; then
    echo -e "${GREEN}✅ GitLab is ready!${NC}"
    echo ""
    
    # Check if port-forward is already running
    if lsof -i :8080 > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Port 8080 is already in use${NC}"
        echo ""
        echo "Port-forward may already be running. Try:"
        echo "  http://localhost:8080"
        echo ""
        echo "Or kill existing port-forward:"
        echo "  pkill -f 'kubectl port-forward.*gitlab'"
    else
        echo "Setting up port-forward..."
        echo ""
        echo -e "${BLUE}Starting port-forward in background...${NC}"
        kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /tmp/gitlab-pf.log 2>&1 &
        PF_PID=$!
        sleep 3
        
        if kill -0 $PF_PID 2>/dev/null; then
            echo -e "${GREEN}✅ Port-forward started (PID: $PF_PID)${NC}"
            echo ""
            echo "Access GitLab at:"
            echo -e "${GREEN}  http://localhost:8080${NC}"
            echo ""
            echo "Default credentials:"
            echo "  Username: root"
            echo "  Password: Check k8s/secret.yaml or token_vault.json"
            echo ""
            echo "To stop port-forward:"
            echo "  kill $PF_PID"
            echo "  or"
            echo "  pkill -f 'kubectl port-forward.*gitlab'"
        else
            echo -e "${RED}❌ Failed to start port-forward${NC}"
            echo "Check logs: cat /tmp/gitlab-pf.log"
            exit 1
        fi
    fi
else
    echo -e "${YELLOW}⚠️  GitLab pod is running but not ready yet${NC}"
    echo ""
    echo "This usually means GitLab is still initializing."
    echo "Check logs:"
    echo "  kubectl logs -n gitlab -l app=gitlab -f"
    echo ""
    echo "Or check pod status:"
    echo "  kubectl describe pod -n gitlab -l app=gitlab"
fi




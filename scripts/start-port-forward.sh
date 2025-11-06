#!/bin/bash
# Start GitLab Port-Forward
# Usage: ./scripts/start-port-forward.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

PORT=8080

echo -e "${BLUE}Starting GitLab port-forward...${NC}"
echo ""

# Check if GitLab is ready
READY=$(kubectl get pods -n gitlab -l app=gitlab -o jsonpath='{.items[0].status.containerStatuses[0].ready}' 2>/dev/null || echo "false")

if [ "$READY" != "true" ]; then
    echo -e "${YELLOW}⚠️  GitLab is not ready yet${NC}"
    echo ""
    echo "Checking status..."
    kubectl get pods -n gitlab -l app=gitlab
    echo ""
    echo "Wait for GitLab to be ready, then run this script again."
    echo "Or check status with: ./scripts/check-gitlab-status.sh"
    exit 1
fi

# Check if port is already in use
if lsof -i :$PORT > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Port $PORT is already in use${NC}"
    echo ""
    echo "Existing process:"
    lsof -i :$PORT
    echo ""
    read -p "Kill existing process and start new port-forward? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        pkill -f "kubectl port-forward.*gitlab.*$PORT" || true
        sleep 2
    else
        echo "Exiting. Use existing port-forward or kill it manually."
        exit 0
    fi
fi

# Start port-forward
echo "Starting port-forward: localhost:$PORT → gitlab-service:80"
kubectl port-forward -n gitlab service/gitlab-service $PORT:80




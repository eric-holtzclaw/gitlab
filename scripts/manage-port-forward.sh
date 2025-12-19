#!/bin/bash
# GitLab Port Forward Management Script
# Production-ready script for managing GitLab port forwards
# Usage: ./manage-port-forward.sh [start|stop|status|restart]

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

GITLAB_NAMESPACE="gitlab"
GITLAB_SERVICE="gitlab-service"
HTTP_PORT=8080
SSH_PORT=2222

LOG_FILE="/tmp/gitlab-portforward.log"

# Function to check if port forward is running
check_port_forward() {
    local PORT=$1
    if lsof -i :$PORT > /dev/null 2>&1; then
        if pgrep -f "kubectl port-forward.*gitlab.*$PORT" > /dev/null; then
            return 0
        fi
    fi
    return 1
}

# Function to start port forward
start_port_forward() {
    local PORT=$1
    local REMOTE_PORT=$2
    local NAME=$3
    
    if check_port_forward $PORT; then
        echo -e "${YELLOW}⚠️  $NAME port forward already running on port $PORT${NC}"
        return 0
    fi
    
    echo -e "${BLUE}Starting $NAME port forward (localhost:$PORT → gitlab-service:$REMOTE_PORT)...${NC}"
    
    # Wait for kubectl and GitLab to be ready
    echo -e "${BLUE}Waiting for GitLab service to be ready...${NC}"
    for i in {1..30}; do
        if kubectl get svc -n $GITLAB_NAMESPACE $GITLAB_SERVICE > /dev/null 2>&1; then
            break
        fi
        if [ $i -eq 30 ]; then
            echo -e "${RED}❌ GitLab service not found after 60 seconds${NC}"
            return 1
        fi
        sleep 2
    done
    
    # Start port forward
    kubectl port-forward -n $GITLAB_NAMESPACE service/$GITLAB_SERVICE $PORT:$REMOTE_PORT > /tmp/gitlab-$NAME-pf.log 2>&1 &
    local PF_PID=$!
    
    # Wait and verify
    sleep 3
    if check_port_forward $PORT; then
        echo -e "${GREEN}✅ $NAME port forward started (PID: $PF_PID)${NC}"
        echo "$(date): ✅ $NAME port forward started on port $PORT (PID: $PF_PID)" >> "$LOG_FILE"
        return 0
    else
        echo -e "${RED}❌ $NAME port forward failed to start${NC}"
        echo "$(date): ❌ $NAME port forward failed on port $PORT" >> "$LOG_FILE"
        cat /tmp/gitlab-$NAME-pf.log 2>&1 | tail -5
        return 1
    fi
}

# Function to stop port forward
stop_port_forward() {
    local PORT=$1
    local NAME=$2
    
    echo -e "${BLUE}Stopping $NAME port forward...${NC}"
    pkill -f "kubectl port-forward.*gitlab.*$PORT" 2>/dev/null || true
    sleep 2
    
    if check_port_forward $PORT; then
        echo -e "${RED}❌ Failed to stop $NAME port forward${NC}"
        return 1
    else
        echo -e "${GREEN}✅ $NAME port forward stopped${NC}"
        echo "$(date): ✅ $NAME port forward stopped on port $PORT" >> "$LOG_FILE"
        return 0
    fi
}

# Function to show status
show_status() {
    echo -e "${CYAN}GitLab Port Forward Status${NC}"
    echo "================================"
    echo ""
    
    # Check HTTP port
    if check_port_forward $HTTP_PORT; then
        echo -e "${GREEN}✅ HTTP port forward: Running on port $HTTP_PORT${NC}"
        lsof -i :$HTTP_PORT | grep LISTEN | head -1
    else
        echo -e "${RED}❌ HTTP port forward: Not running${NC}"
    fi
    echo ""
    
    # Check SSH port
    if check_port_forward $SSH_PORT; then
        echo -e "${GREEN}✅ SSH port forward: Running on port $SSH_PORT${NC}"
        lsof -i :$SSH_PORT | grep LISTEN | head -1
    else
        echo -e "${RED}❌ SSH port forward: Not running${NC}"
    fi
    echo ""
    
    # Check LaunchAgent
    if launchctl list | grep -q com.gitlab.portforward; then
        echo -e "${GREEN}✅ LaunchAgent: Loaded${NC}"
    else
        echo -e "${YELLOW}⚠️  LaunchAgent: Not loaded${NC}"
    fi
    echo ""
}

# Function to test connections
test_connections() {
    echo -e "${CYAN}Testing GitLab Connections${NC}"
    echo "================================"
    echo ""
    
    # Test HTTP
    echo -e "${BLUE}Testing HTTP (port $HTTP_PORT)...${NC}"
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:$HTTP_PORT | grep -q "200\|302\|401"; then
        echo -e "${GREEN}✅ HTTP connection successful${NC}"
    else
        echo -e "${RED}❌ HTTP connection failed${NC}"
    fi
    echo ""
    
    # Test SSH
    echo -e "${BLUE}Testing SSH (port $SSH_PORT)...${NC}"
    SSH_TEST=$(ssh -T -p $SSH_PORT -o ConnectTimeout=5 -o StrictHostKeyChecking=no git@localhost 2>&1 || true)
    if echo "$SSH_TEST" | grep -q "Welcome to GitLab\|You've successfully authenticated"; then
        echo -e "${GREEN}✅ SSH connection successful${NC}"
        echo "$SSH_TEST" | head -2
    else
        echo -e "${YELLOW}⚠️  SSH test output:${NC}"
        echo "$SSH_TEST" | head -3
    fi
    echo ""
}

# Main command handler
case "${1:-status}" in
    start)
        echo -e "${GREEN}Starting GitLab port forwards...${NC}"
        echo ""
        start_port_forward $HTTP_PORT 80 http
        start_port_forward $SSH_PORT 2222 ssh
        echo ""
        test_connections
        ;;
    stop)
        echo -e "${YELLOW}Stopping GitLab port forwards...${NC}"
        echo ""
        stop_port_forward $HTTP_PORT http
        stop_port_forward $SSH_PORT ssh
        ;;
    restart)
        echo -e "${CYAN}Restarting GitLab port forwards...${NC}"
        echo ""
        stop_port_forward $HTTP_PORT http
        stop_port_forward $SSH_PORT ssh
        sleep 2
        start_port_forward $HTTP_PORT 80 http
        start_port_forward $SSH_PORT 2222 ssh
        echo ""
        test_connections
        ;;
    status)
        show_status
        test_connections
        ;;
    test)
        test_connections
        ;;
    *)
        echo "Usage: $0 [start|stop|restart|status|test]"
        echo ""
        echo "Commands:"
        echo "  start   - Start HTTP and SSH port forwards"
        echo "  stop    - Stop HTTP and SSH port forwards"
        echo "  restart - Restart HTTP and SSH port forwards"
        echo "  status  - Show status of port forwards"
        echo "  test    - Test HTTP and SSH connections"
        exit 1
        ;;
esac


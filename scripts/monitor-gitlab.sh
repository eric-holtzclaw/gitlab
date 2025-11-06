#!/bin/bash
# GitLab Health Monitoring Script
# Monitors GitLab pod status and restarts port-forward if needed
# Usage: Can be run manually or via cron

# Don't use set -e - we want to handle errors and take corrective actions

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

LOG_FILE="/tmp/gitlab-monitor.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

log() {
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

check_gitlab_pod() {
    local STATUS=$(kubectl get pods -n gitlab -l app=gitlab -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NotFound")
    local READY=$(kubectl get pods -n gitlab -l app=gitlab -o jsonpath='{.items[0].status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
    local RESTARTS=$(kubectl get pods -n gitlab -l app=gitlab -o jsonpath='{.items[0].status.containerStatuses[0].restartCount}' 2>/dev/null || echo "0")
    
    echo "$STATUS|$READY|$RESTARTS"
}

check_port_forward() {
    if lsof -i :8080 > /dev/null 2>&1; then
        echo "running"
    else
        echo "stopped"
    fi
}

check_gitlab_http() {
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 --max-time 5 2>/dev/null | grep -q "200\|302"; then
        echo "healthy"
    else
        echo "unhealthy"
    fi
}

# Main monitoring
log "=== GitLab Health Check ==="

# Check pod status
POD_INFO=$(check_gitlab_pod)
STATUS=$(echo "$POD_INFO" | cut -d'|' -f1)
READY=$(echo "$POD_INFO" | cut -d'|' -f2)
RESTARTS=$(echo "$POD_INFO" | cut -d'|' -f3)

log "Pod Status: $STATUS"
log "Pod Ready: $READY"
log "Pod Restarts: $RESTARTS"

# Check port-forward
PF_STATUS=$(check_port_forward)
log "Port-Forward (8080): $PF_STATUS"

# Check HTTP health
HTTP_STATUS=$(check_gitlab_http)
log "HTTP Health: $HTTP_STATUS"

# Determine overall status
if [ "$STATUS" = "Running" ] && [ "$READY" = "true" ] && [ "$PF_STATUS" = "running" ] && [ "$HTTP_STATUS" = "healthy" ]; then
    log "${GREEN}✅ GitLab is UP and healthy${NC}"
    exit 0
elif [ "$STATUS" = "Running" ] && [ "$READY" = "false" ]; then
    log "${YELLOW}⚠️  GitLab pod is running but not ready (still initializing)${NC}"
    exit 0
elif [ "$STATUS" = "CrashLoopBackOff" ] || [ "$STATUS" = "Error" ]; then
    log "${RED}❌ GitLab pod is CRASHING${NC}"
    log "Checking logs..."
    kubectl logs -n gitlab -l app=gitlab --tail=20 2>&1 | tail -10 >> "$LOG_FILE"
    # Check if it's a permission error
    if kubectl logs -n gitlab -l app=gitlab --tail=50 2>&1 | grep -qi "permission denied\|fatal.*permission"; then
        log "${YELLOW}⚠️  Permission error detected - restarting pod to trigger init container${NC}"
        kubectl delete pod -n gitlab -l app=gitlab --force --grace-period=0 2>&1 | head -1 >> "$LOG_FILE"
        log "${BLUE}Pod deleted, will recreate with permission fix${NC}"
    fi
    exit 1
elif [ "$PF_STATUS" = "stopped" ]; then
    log "${YELLOW}⚠️  Port-forward not running, starting it...${NC}"
    # Kill any existing port-forwards
    pkill -f "kubectl port-forward.*gitlab.*8080" 2>/dev/null || true
    sleep 1
    # Start port-forward in background
    nohup kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /tmp/gitlab-pf.log 2>&1 &
    PF_PID=$!
    sleep 3
    if lsof -i :8080 > /dev/null 2>&1; then
        log "${GREEN}✅ Port-forward started (PID: $PF_PID)${NC}"
    else
        log "${RED}❌ Failed to start port-forward${NC}"
        # Try SSH port-forward too
        pkill -f "kubectl port-forward.*gitlab.*2222" 2>/dev/null || true
        nohup kubectl port-forward -n gitlab service/gitlab-service 2222:2222 > /tmp/gitlab-ssh-pf.log 2>&1 &
        exit 1
    fi
    exit 0
elif [ "$HTTP_STATUS" = "unhealthy" ]; then
    log "${RED}❌ GitLab HTTP not responding${NC}"
    # If pod is running but HTTP unhealthy for > 10 minutes, restart
    if [ "$RESTARTS" -lt 5 ]; then
        log "${YELLOW}Checking if stuck...${NC}"
        # Check if it's been unhealthy for a while (pod age > 10 min)
        POD_CREATED=$(kubectl get pods -n gitlab -l app=gitlab -o jsonpath='{.items[0].metadata.creationTimestamp}' 2>/dev/null || echo "")
        if [ -n "$POD_CREATED" ]; then
            # Get pod age in minutes (simplified - just check if creation time is old)
            POD_AGE_TEXT=$(kubectl get pods -n gitlab -l app=gitlab -o jsonpath='{.items[0].metadata.creationTimestamp}' 2>/dev/null || echo "")
            if [ -n "$POD_AGE_TEXT" ]; then
                log "${YELLOW}Pod created: ${POD_AGE_TEXT}${NC}"
                # If pod is > 10 minutes old and still not ready, it's likely stuck
                if [ "$READY" = "false" ]; then
                    log "${YELLOW}⚠️  Pod still not ready - may need intervention${NC}"
                fi
            fi
        fi
    fi
    exit 1
else
    log "${YELLOW}⚠️  GitLab status unclear: Status=$STATUS, Ready=$READY${NC}"
    exit 1
fi


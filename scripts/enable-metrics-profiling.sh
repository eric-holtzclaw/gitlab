#!/bin/bash
# Enable GitLab metrics and profiling
# See: http://localhost:8080/admin/application_settings/metrics_and_profiling

set -e

GITLAB_URL="http://localhost:8080"
GITLAB_TOKEN="glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Enabling Metrics & Profiling ===${NC}"

# Check if port-forward is running
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo "⚠️  GitLab port-forward not running. Starting it..."
    pkill -f "kubectl port-forward.*gitlab.*8080" 2>/dev/null || true
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /tmp/gitlab-http-port-forward.log 2>&1 &
    sleep 3
fi

# Enable metrics and profiling via Admin API
RESULT=$(curl -s --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "metrics_enabled": true,
    "metrics_host": "localhost",
    "metrics_port": 8089,
    "metrics_packet_size": 1,
    "metrics_sample_interval": 15,
    "metrics_pool_size": 16,
    "metrics_timeout": 10,
    "metrics_method_call_threshold": 10,
    "performance_bar_enabled": true,
    "performance_bar_allowed_group_path": null,
    "html_emails_enabled": true,
    "sentry_enabled": false,
    "recaptcha_enabled": false,
    "mailgun_events_enabled": false,
    "usage_ping_enabled": true,
    "version_check_enabled": true,
    "prometheus_metrics_enabled": true,
    "prometheus_metrics_authorized": true,
    "grafana_enabled": false,
    "grafana_url": "",
    "gitlab_health_check_access_token": null
  }' \
  "${GITLAB_URL}/api/v4/application/settings" 2>&1)

if echo "$RESULT" | grep -q '"metrics_enabled":true'; then
    echo -e "${GREEN}✅ Metrics & Profiling enabled successfully!${NC}"
else
    # Check if already enabled or if there's an error
    if echo "$RESULT" | grep -q "metrics_enabled"; then
        echo -e "${GREEN}✅ Metrics already enabled${NC}"
    else
        echo -e "${YELLOW}⚠️  Response: $RESULT${NC}" | head -5
    fi
fi

echo ""
echo -e "${BLUE}📊 Access metrics:${NC}"
echo "   - Prometheus: http://localhost:8080/-/metrics"
echo "   - Performance Bar: Press 'p' in GitLab UI (if enabled)"
echo ""
echo -e "${BLUE}🌐 Settings UI:${NC}"
echo "   http://localhost:8080/admin/application_settings/metrics_and_profiling"
echo ""
echo -e "${YELLOW}ℹ️  Note:${NC} Prometheus and Grafana may need additional configuration"
echo "   in the GitLab ConfigMap for full metrics collection."


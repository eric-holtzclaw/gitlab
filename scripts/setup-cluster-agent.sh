#!/bin/bash
# Setup GitLab Cluster Agent for Kubernetes integration
# See: https://docs.gitlab.com/18.5/user/clusters/agent/

set -e

GITLAB_URL="http://localhost:8080"
GITLAB_TOKEN="glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== GitLab Cluster Agent Setup Guide ===${NC}"
echo ""

# Check if port-forward is running
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo "⚠️  GitLab port-forward not running. Starting it..."
    pkill -f "kubectl port-forward.*gitlab.*8080" 2>/dev/null || true
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /tmp/gitlab-http-port-forward.log 2>&1 &
    sleep 3
fi

echo -e "${CYAN}Step 1: Create Agent Configuration in Repository${NC}"
echo ""
echo "Create agent configuration file:"
echo ""
echo "File: .gitlab/agents/kubernetes/config.yaml"
echo ""
cat <<'EOF'
# .gitlab/agents/kubernetes/config.yaml
# GitLab Agent configuration for Kubernetes

gitops:
  manifest_projects:
    - id: infrastructure/core
      default_namespace: default
      paths:
        - glob: 'k8s/**/*.yaml'
        - glob: 'k8s-devops/**/*.yaml'
EOF

echo ""
echo -e "${CYAN}Step 2: Create Agent in GitLab UI${NC}"
echo ""
echo "1. Go to: ${GITLAB_URL}/infrastructure/core/-/clusters/new"
echo "2. Click 'Create agent'"
echo "3. Agent name: 'kubernetes'"
echo "4. Click 'Register agent'"
echo "5. Copy the agent token (you'll need it for Step 3)"
echo ""

echo -e "${CYAN}Step 3: Install Agent in Kubernetes${NC}"
echo ""
echo "Option A: Using Helm (Recommended)"
echo "  helm repo add gitlab https://charts.gitlab.io"
echo "  helm repo update"
echo "  helm install gitlab-agent gitlab/gitlab-agent \\"
echo "    --namespace gitlab-agent \\"
echo "    --create-namespace \\"
echo "    --set config.token=YOUR_AGENT_TOKEN \\"
echo "    --set config.kasAddress=ws://gitlab-service.gitlab.svc.cluster.local/-/kubernetes-agent/"
echo ""

echo "Option B: Using kubectl (Direct manifest)"
echo "  kubectl create namespace gitlab-agent"
echo "  # Then apply agentk deployment with token from GitLab UI"
echo ""

echo -e "${GREEN}✅ Benefits of Cluster Agent:${NC}"
echo "   • Secure: No SSH keys or kubeconfig in CI/CD variables"
echo "   • Real-time: Direct Kubernetes API access"
echo "   • Audit trail: All cluster operations logged"
echo "   • GitOps: Automatic deployment from repository changes"
echo ""

echo -e "${YELLOW}ℹ️  Note:${NC} This requires GitLab 14.0+ and Kubernetes 1.17+"
echo "   Your GitLab version should support this feature."



#!/bin/bash
# Automated GitLab Deployment Script
# Usage: ./scripts/deploy-gitlab.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
K8S_DIR="$PROJECT_ROOT/k8s"

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}GitLab Kubernetes Deployment${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl not found. Please install kubectl.${NC}"
    echo -e "${BLUE}💡 Reference: https://github.com/eric-holtzclaw/core/k8s-devops${NC}"
    exit 1
fi

# Check if token_vault.json exists (optional for GitLab)
if [ ! -f "$PROJECT_ROOT/token_vault.json" ]; then
    echo -e "${YELLOW}⚠️  token_vault.json not found.${NC}"
    echo "Creating from example..."
    if [ -f "$PROJECT_ROOT/token_vault.json.example" ]; then
        cp "$PROJECT_ROOT/token_vault.json.example" "$PROJECT_ROOT/token_vault.json"
        echo ""
        echo -e "${YELLOW}⚠️  Please edit token_vault.json with your GitLab root password!${NC}"
        echo "  1. Set GITLAB_ROOT_PASSWORD (change default password)"
        echo "  2. Optionally set GITLAB_ROOT_EMAIL"
        echo ""
        echo "Press Enter when ready, or Ctrl+C to cancel..."
        read
    fi
fi

# Generate Kubernetes Secret from vault (if vault script exists)
if [ -f "$SCRIPT_DIR/vault-to-k8s-secret.sh" ]; then
    echo -e "${BLUE}[1/7] Generating Kubernetes Secret from token vault...${NC}"
    bash "$SCRIPT_DIR/vault-to-k8s-secret.sh"
else
    echo -e "${YELLOW}⚠️  vault-to-k8s-secret.sh not found, using manual secret.yaml${NC}"
    if [ ! -f "$K8S_DIR/secret.yaml" ]; then
        echo -e "${RED}❌ secret.yaml not found. Please create it manually.${NC}"
        exit 1
    fi
fi

# Apply manifests in order
echo ""
echo -e "${BLUE}[2/7] Creating namespace...${NC}"
kubectl apply -f "$K8S_DIR/namespace.yaml"

echo -e "${BLUE}[3/7] Creating persistent volume...${NC}"
kubectl apply -f "$K8S_DIR/pv-local.yaml"

echo -e "${BLUE}[4/7] Creating persistent volume claim...${NC}"
kubectl apply -f "$K8S_DIR/pvc.yaml"

echo -e "${BLUE}[5/7] Creating configuration...${NC}"
kubectl apply -f "$K8S_DIR/configmap.yaml"

echo -e "${BLUE}[6/7] Creating secrets...${NC}"
kubectl apply -f "$K8S_DIR/secret.yaml"

echo -e "${BLUE}[7/7] Deploying GitLab...${NC}"
kubectl apply -f "$K8S_DIR/deployment.yaml"
kubectl apply -f "$K8S_DIR/service.yaml"

echo ""
echo -e "${GREEN}✅ Deployment complete!${NC}"
echo ""
echo -e "${YELLOW}⚠️  GitLab takes 5-10 minutes to fully start up.${NC}"
echo ""
echo "Waiting for GitLab to be ready (this may take several minutes)..."
kubectl wait --for=condition=available --timeout=900s deployment/gitlab -n gitlab || {
    echo -e "${YELLOW}⚠️  Deployment taking longer than expected. Checking status...${NC}"
    kubectl get pods -n gitlab
    echo ""
    echo "GitLab is still starting. Check logs with:"
    echo "  kubectl logs -n gitlab deployment/gitlab -f"
}

echo ""
echo -e "${GREEN}GitLab is ready!${NC}"
echo ""
echo "📋 Access Information:"
echo "  • Internal access (via SASE VPN):"
echo "    kubectl port-forward -n gitlab service/gitlab-service 8080:80"
echo "    Then open: http://localhost:8080"
echo ""
echo "  • SSH access (for Git operations):"
echo "    kubectl port-forward -n gitlab service/gitlab-service 2222:2222"
echo ""
echo "📊 Check Status:"
echo "  kubectl get pods -n gitlab"
echo "  kubectl logs -n gitlab deployment/gitlab -f"
echo ""
echo "🔑 Default Credentials:"
echo "  Username: root"
echo "  Password: Check secret.yaml or token_vault.json"
echo ""
echo -e "${BLUE}💡 Remember: GitLab is behind firewall (10.0.0.1) and accessible via SASE VPN${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Change the root password after first login!${NC}"




#!/bin/bash
# Convert token_vault.json to Kubernetes Secret
# Usage: ./scripts/vault-to-k8s-secret.sh

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VAULT_FILE="$PROJECT_ROOT/token_vault.json"
SECRET_FILE="$PROJECT_ROOT/k8s/secret.yaml"
NAMESPACE="${1:-gitlab}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Converting token_vault.json to Kubernetes Secret...${NC}"
echo ""

# Check if token_vault.json exists
if [ ! -f "$VAULT_FILE" ]; then
    echo -e "${RED}❌ token_vault.json not found at: $VAULT_FILE${NC}"
    echo -e "${YELLOW}💡 Copy token_vault.json.example to token_vault.json and fill in your values${NC}"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠️  jq not found. Installing via Homebrew...${NC}"
    if command -v brew &> /dev/null; then
        brew install jq
    else
        echo -e "${RED}❌ jq is required. Install via: brew install jq${NC}"
        exit 1
    fi
fi

# Read values from token vault
echo "Reading values from token vault..."

GITLAB_ROOT_PASSWORD=$(jq -r '.gitlab.root_password' "$VAULT_FILE")
GITLAB_ROOT_EMAIL=$(jq -r '.gitlab.root_email // "admin@gitlab.local"' "$VAULT_FILE")

# Validate required values
if [ "$GITLAB_ROOT_PASSWORD" = "null" ] || [ -z "$GITLAB_ROOT_PASSWORD" ]; then
    echo -e "${RED}❌ Missing required values in token_vault.json${NC}"
    echo "Required: gitlab.root_password"
    exit 1
fi

# Check for placeholder values
if [ "$GITLAB_ROOT_PASSWORD" = "ChangeMe123!@#SecurePassword" ]; then
    echo -e "${YELLOW}⚠️  Warning: Using default password!${NC}"
    echo "Please update token_vault.json with a strong password before deploying."
    echo ""
fi

# Create Kubernetes Secret manifest
echo "Generating Kubernetes Secret manifest..."
mkdir -p "$(dirname "$SECRET_FILE")"

cat > "$SECRET_FILE" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-secrets
  namespace: $NAMESPACE
type: Opaque
stringData:
  # GitLab Root Password (initial root user password)
  # This will be set during first setup, change it after first login
  GITLAB_ROOT_PASSWORD: "$GITLAB_ROOT_PASSWORD"
  
  # GitLab Initial Root Email (optional)
  GITLAB_ROOT_EMAIL: "$GITLAB_ROOT_EMAIL"
  
  # Note: Additional secrets can be added here
  # For production, use external secret management (Vault, etc.)
EOF

echo ""
echo -e "${GREEN}✅ Kubernetes Secret generated: $SECRET_FILE${NC}"
echo ""
echo "To apply the secret:"
echo "  kubectl apply -f $SECRET_FILE"
echo ""
echo -e "${YELLOW}⚠️  Remember: token_vault.json contains sensitive data - never commit it!${NC}"
echo -e "${YELLOW}⚠️  IMPORTANT: Change the root password after first GitLab login!${NC}"




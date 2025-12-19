#!/bin/bash
# Validate secret management setup
# Checks that secrets are properly configured across all services
# Usage: ./scripts/validate-secrets.sh

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}Secret Management Validation${NC}"
echo -e "${CYAN}==========================================${NC}"
echo ""

# Check GitLab token_vault.json
echo -e "${BLUE}1. Checking GitLab token_vault.json...${NC}"
if [ -f "token_vault.json" ]; then
    if command -v jq &> /dev/null; then
        GITLAB_PASSWORD=$(jq -r '.gitlab.root_password // "null"' token_vault.json 2>/dev/null)
        if [ "$GITLAB_PASSWORD" != "null" ] && [ "$GITLAB_PASSWORD" != "ChangeMe123!@#SecurePassword" ]; then
            echo -e "${GREEN}  ✅ token_vault.json exists and has GitLab password${NC}"
        else
            echo -e "${YELLOW}  ⚠️  token_vault.json exists but using default password${NC}"
        fi
    else
        echo -e "${YELLOW}  ⚠️  token_vault.json exists (jq not installed to validate)${NC}"
    fi
else
    echo -e "${RED}  ❌ token_vault.json not found${NC}"
fi
echo ""

# Check GitLab K8s secret
echo -e "${BLUE}2. Checking GitLab Kubernetes secret...${NC}"
if kubectl get secret gitlab-secrets -n gitlab &>/dev/null; then
    echo -e "${GREEN}  ✅ GitLab secret exists in Kubernetes${NC}"
else
    echo -e "${YELLOW}  ⚠️  GitLab secret not found in Kubernetes${NC}"
    echo "     Run: bash scripts/vault-to-k8s-secret.sh"
fi
echo ""

# Check GitLab CI/CD variables
echo -e "${BLUE}3. Checking GitLab CI/CD Variables...${NC}"
GITLAB_URL="http://localhost:8080"
GITLAB_TOKEN="glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3"

if ! lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${YELLOW}  ⚠️  GitLab port-forward not running${NC}"
    echo "     Skipping CI/CD variable check"
else
    PROJECTS=("infrastructure/core" "infrastructure/supabase" "infrastructure/nginx")
    for PROJECT_PATH in "${PROJECTS[@]}"; do
        ENCODED_PATH="${PROJECT_PATH//\//%2F}"
        PROJECT_ID=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
            "${GITLAB_URL}/api/v4/projects/${ENCODED_PATH}" | \
            python3 -c "import sys, json; print(json.load(sys.stdin).get('id', ''))" 2>/dev/null)
        
        if [ -n "$PROJECT_ID" ] && [ "$PROJECT_ID" != "None" ]; then
            VARIABLES=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
                "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/variables" 2>/dev/null)
            
            VAR_COUNT=$(echo "$VARIABLES" | python3 -c "import sys, json; vars=json.load(sys.stdin); print(len(vars))" 2>/dev/null || echo "0")
            
            if [ "$VAR_COUNT" -gt 0 ]; then
                echo -e "${GREEN}  ✅ ${PROJECT_PATH}: ${VAR_COUNT} CI/CD variable(s) configured${NC}"
            else
                echo -e "${YELLOW}  ⚠️  ${PROJECT_PATH}: No CI/CD variables configured${NC}"
            fi
        fi
    done
fi
echo ""

# Check Supabase secrets
echo -e "${BLUE}4. Checking Supabase secrets...${NC}"
if [ -d "../supabase" ] && [ -f "../supabase/token_vault.json" ]; then
    echo -e "${GREEN}  ✅ Supabase token_vault.json exists${NC}"
    
    if kubectl get secret supabase-secrets -n supabase &>/dev/null; then
        echo -e "${GREEN}  ✅ Supabase secret exists in Kubernetes${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Supabase secret not found in Kubernetes${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  Supabase directory not found or token_vault.json missing${NC}"
fi
echo ""

# Check .gitignore
echo -e "${BLUE}5. Checking .gitignore...${NC}"
if [ -f ".gitignore" ]; then
    if grep -q "token_vault.json" .gitignore && grep -q "secret.yaml" .gitignore; then
        echo -e "${GREEN}  ✅ .gitignore properly configured${NC}"
    else
        echo -e "${YELLOW}  ⚠️  .gitignore may be missing secret patterns${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  .gitignore not found${NC}"
fi
echo ""

echo -e "${CYAN}==========================================${NC}"
echo -e "${BLUE}Validation Complete${NC}"
echo -e "${CYAN}==========================================${NC}"
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "  1. Ensure all token_vault.json files are in .gitignore"
echo "  2. Run: bash scripts/vault-to-k8s-secret.sh (to generate K8s secrets)"
echo "  3. Run: bash scripts/setup-gitlab-ci-cd-variables.sh (to configure CI/CD)"
echo "  4. Review: SECRET_MANAGEMENT_STRATEGY.md"



#!/bin/bash
# Setup GitLab CI/CD Variables for Best Practices
# Adds all required CI/CD secrets to GitLab projects
# Usage: ./scripts/setup-gitlab-ci-cd-variables.sh

set -e

GITLAB_URL="http://localhost:8080"
GITLAB_TOKEN="glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}GitLab CI/CD Variables Setup${NC}"
echo -e "${CYAN}==========================================${NC}"
echo ""

# Check if port-forward is running
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo "⚠️  GitLab port-forward not running. Starting it..."
    pkill -f "kubectl port-forward.*gitlab.*8080" 2>/dev/null || true
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /tmp/gitlab-http-port-forward.log 2>&1 &
    sleep 3
fi

# Function to add CI/CD variable to a project
add_variable() {
    local PROJECT_ID=$1
    local KEY=$2
    local VALUE=$3
    local MASKED=${4:-true}
    local PROTECTED=${5:-true}
    
    # Check if variable already exists
    EXISTING=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/variables/${KEY}" 2>/dev/null)
    
    if echo "$EXISTING" | grep -q '"key"'; then
        echo -e "${YELLOW}  ⚠️  ${KEY} already exists, updating...${NC}"
        METHOD="PUT"
        URL="${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/variables/${KEY}"
    else
        METHOD="POST"
        URL="${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/variables"
    fi
    
    RESULT=$(curl -s --request "$METHOD" \
        --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        --header "Content-Type: application/json" \
        --data "{
            \"key\": \"${KEY}\",
            \"value\": \"${VALUE}\",
            \"masked\": ${MASKED},
            \"protected\": ${PROTECTED}
        }" \
        "$URL" 2>&1)
    
    if echo "$RESULT" | grep -q '"key"'; then
        echo -e "${GREEN}  ✅ ${KEY} configured${NC}"
        return 0
    else
        echo -e "${RED}  ❌ Failed to configure ${KEY}${NC}"
        echo "     Response: $RESULT" | head -2
        return 1
    fi
}

# Function to get project ID by path
get_project_id() {
    local PROJECT_PATH=$1
    local ENCODED_PATH="${PROJECT_PATH//\//%2F}"
    
    curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "${GITLAB_URL}/api/v4/projects/${ENCODED_PATH}" | \
        python3 -c "import sys, json; print(json.load(sys.stdin).get('id', ''))" 2>/dev/null
}

# Projects that need CI/CD variables
PROJECTS=(
    "infrastructure/core"
    "infrastructure/supabase"
    "infrastructure/nginx"
)

echo -e "${BLUE}Projects to configure:${NC}"
for project in "${PROJECTS[@]}"; do
    echo "  • $project"
done
echo ""

# Prompt for secrets
echo -e "${YELLOW}📋 Required Secrets:${NC}"
echo ""
echo "You'll need to provide:"
echo "  1. GitHub Personal Access Token (for mirroring)"
echo "  2. Docker Hub credentials (optional)"
echo "  3. Kubernetes kubeconfig (optional)"
echo ""

# GitHub Token
read -sp "GitHub Personal Access Token (repo scope): " GITHUB_TOKEN
echo ""
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${YELLOW}⚠️  Skipping GitHub token (can add later)${NC}"
else
    echo -e "${GREEN}✅ GitHub token provided${NC}"
fi
echo ""

# Docker Hub (optional)
read -p "Docker Hub Username (optional, press Enter to skip): " DOCKERHUB_USER
if [ -n "$DOCKERHUB_USER" ]; then
    read -sp "Docker Hub Password: " DOCKERHUB_PASSWORD
    echo ""
fi
echo ""

# Kubernetes Config (optional)
read -p "Add Kubernetes kubeconfig? (y/N): " ADD_K8S
if [ "$ADD_K8S" = "y" ] || [ "$ADD_K8S" = "Y" ]; then
    if [ -f ~/.kube/config ]; then
        K8S_CONFIG=$(cat ~/.kube/config | base64)
        echo -e "${GREEN}✅ K8s config loaded${NC}"
    else
        echo -e "${YELLOW}⚠️  ~/.kube/config not found${NC}"
        K8S_CONFIG=""
    fi
else
    K8S_CONFIG=""
fi
echo ""

# Process each project
TOTAL_SUCCESS=0
TOTAL_FAILED=0

for PROJECT_PATH in "${PROJECTS[@]}"; do
    echo ""
    echo -e "${CYAN}=== Configuring: ${PROJECT_PATH} ===${NC}"
    
    PROJECT_ID=$(get_project_id "$PROJECT_PATH")
    
    if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "None" ]; then
        echo -e "${RED}❌ Project not found${NC}"
        ((TOTAL_FAILED++))
        continue
    fi
    
    echo "Project ID: $PROJECT_ID"
    echo ""
    
    # GitHub Token
    if [ -n "$GITHUB_TOKEN" ]; then
        add_variable "$PROJECT_ID" "GITHUB_TOKEN" "$GITHUB_TOKEN" true true
    fi
    
    # Docker Hub
    if [ -n "$DOCKERHUB_USER" ] && [ -n "$DOCKERHUB_PASSWORD" ]; then
        add_variable "$PROJECT_ID" "DOCKERHUB_USER" "$DOCKERHUB_USER" false true
        add_variable "$PROJECT_ID" "DOCKERHUB_PASSWORD" "$DOCKERHUB_PASSWORD" true true
    fi
    
    # Kubernetes Config
    if [ -n "$K8S_CONFIG" ]; then
        add_variable "$PROJECT_ID" "K8S_CONFIG" "$K8S_CONFIG" true true
    fi
    
    echo -e "${GREEN}✅ Configuration complete for ${PROJECT_PATH}${NC}"
    ((TOTAL_SUCCESS++))
done

echo ""
echo -e "${CYAN}==========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${CYAN}==========================================${NC}"
echo ""
echo -e "${BLUE}Summary:${NC}"
echo -e "${GREEN}✅ Successfully configured: ${TOTAL_SUCCESS} projects${NC}"
echo -e "${RED}❌ Failed: ${TOTAL_FAILED} projects${NC}"
echo ""
echo -e "${BLUE}Verify in GitLab UI:${NC}"
for PROJECT_PATH in "${PROJECTS[@]}"; do
    ENCODED="${PROJECT_PATH//\//%2F}"
    echo "  http://localhost:8080/${PROJECT_PATH}/-/settings/ci_cd#js-ci-cd-variables"
done
echo ""
echo -e "${YELLOW}ℹ️  Note: Masked variables won't be visible in the UI${NC}"
echo "   They'll be available as environment variables in CI/CD pipelines"



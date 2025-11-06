#!/bin/bash
# Create new repositories with standard CI/CD template

set -e

PROJECT_NAME=$1
GROUP=$2

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ -z "$PROJECT_NAME" ] || [ -z "$GROUP" ]; then
    echo -e "${RED}Usage: $0 <project-name> <group>${NC}"
    echo ""
    echo "Example:"
    echo "  $0 my-new-project infrastructure"
    echo ""
    echo "Available groups:"
    echo "  - infrastructure"
    echo "  - applications"
    echo "  - microsoft-development"
    echo "  - open-source-development"
    echo "  - automation"
    exit 1
fi

GITLAB_URL="http://localhost:8080"
GITLAB_TOKEN="glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3"

# Check if port-forward is running
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo "⚠️  GitLab port-forward not running. Starting it..."
    pkill -f "kubectl port-forward.*gitlab.*8080" 2>/dev/null || true
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /tmp/gitlab-http-port-forward.log 2>&1 &
    sleep 3
fi

echo -e "${BLUE}=== Creating Repository Template ===${NC}"
echo "Project: $PROJECT_NAME"
echo "Group: $GROUP"
echo ""

# Create project
echo -e "${BLUE}Creating project...${NC}"
RESULT=$(curl -s --request POST \
    --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    --header "Content-Type: application/json" \
    --data "{
        \"name\":\"$PROJECT_NAME\",
        \"namespace_id\":null,
        \"path\":\"$PROJECT_NAME\",
        \"visibility\":\"private\",
        \"initialize_with_readme\":true
    }" \
    "http://localhost:8080/api/v4/projects?namespace=$GROUP" 2>&1)

PROJECT_ID=$(echo "$RESULT" | python3 -c "import sys, json; print(json.load(sys.stdin).get('id', ''))" 2>/dev/null)

if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "None" ]; then
    if echo "$RESULT" | grep -q "has already been taken"; then
        echo -e "${YELLOW}⚠️  Project already exists${NC}"
        echo "Getting existing project ID..."
        
        ENCODED_PATH="${GROUP}/${PROJECT_NAME}"
        ENCODED_PATH="${ENCODED_PATH//\//%2F}"
        PROJECT_INFO=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
            "${GITLAB_URL}/api/v4/projects/${ENCODED_PATH}")
        PROJECT_ID=$(echo "$PROJECT_INFO" | python3 -c "import sys, json; print(json.load(sys.stdin).get('id', ''))" 2>/dev/null)
    else
        echo -e "${RED}❌ Failed to create project${NC}"
        echo "Response: $RESULT" | head -5
        exit 1
    fi
fi

echo -e "${GREEN}✅ Project created/accessed (ID: $PROJECT_ID)${NC}"
echo ""

# Create standard .gitlab-ci.yml template
echo -e "${BLUE}Creating .gitlab-ci.yml template...${NC}"
cat > /tmp/.gitlab-ci.yml <<'EOF'
stages:
  - test
  - build
  - deploy

variables:
  K8S_SERVER: "eric@10.0.0.10"
  K8S_NAMESPACE: "default"

test:
  stage: test
  image: alpine:latest
  script:
    - echo "Running tests..."
    - echo "Add your test commands here"
    # Example: npm test, pytest, etc.
  only:
    - merge_requests
    - main

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - echo "Docker build would go here"
  script:
    - echo "Building..."
    - echo "Add your build commands here"
  only:
    - main
    - tags

deploy:
  stage: deploy
  image: alpine:latest
  script:
    - echo "Deploying..."
    - echo "Add your deployment commands here"
    # Example: kubectl apply, helm upgrade, etc.
  only:
    - main
  when: manual
EOF

echo -e "${GREEN}✅ Template created${NC}"
echo ""
echo -e "${BLUE}📋 Next steps:${NC}"
echo "1. Clone the repository:"
echo "   git clone http://localhost:8080/${GROUP}/${PROJECT_NAME}.git"
echo ""
echo "2. Add the .gitlab-ci.yml template:"
echo "   cp /tmp/.gitlab-ci.yml .gitlab-ci.yml"
echo "   git add .gitlab-ci.yml"
echo "   git commit -m 'Add CI/CD pipeline'"
echo "   git push"
echo ""
echo "3. Configure CI/CD variables in GitLab:"
echo "   http://localhost:8080/${GROUP}/${PROJECT_NAME}/-/settings/ci_cd"
echo ""
echo "4. View project:"
echo "   http://localhost:8080/${GROUP}/${PROJECT_NAME}"



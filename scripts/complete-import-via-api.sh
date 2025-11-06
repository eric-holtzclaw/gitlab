#!/bin/bash
# Complete Import via GitLab API
# Unprotects branches, merges github-import-main into main, and cleans up
# Usage: ./scripts/complete-import-via-api.sh

set +e  # Don't exit on errors so we can see what's happening

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

GITLAB_URL="http://localhost:8080"
GITLAB_TOKEN="glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3"

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Complete Import via GitLab API${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Check port-forward
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Starting GitLab port-forward...${NC}"
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /dev/null 2>&1 &
    sleep 5
    echo -e "${GREEN}✅ Port-forward started${NC}"
fi

# Projects to process: "group/project_name"
PROJECTS=(
    "infrastructure/core"
    "infrastructure/supabase"
    "microsoft-development/o365-forensics-investigator"
    "open-source-development/kali"
)

# Function to get project ID
get_project_id() {
    local PROJECT_PATH=$1
    local ENCODED_PATH="${PROJECT_PATH//\//%2F}"
    curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        "${GITLAB_URL}/api/v4/projects/${ENCODED_PATH}" | \
        python3 -c "import sys, json; print(json.load(sys.stdin).get('id', ''))" 2>/dev/null
}

# Function to unprotect branch
unprotect_branch() {
    local PROJECT_ID=$1
    local BRANCH_NAME=$2
    
    echo -e "${BLUE}  Unprotecting ${BRANCH_NAME} branch...${NC}"
    
    # First, check if branch is protected
    PROTECTED=$(curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/protected_branches/${BRANCH_NAME}" 2>&1)
    
    if echo "$PROTECTED" | grep -q '"name"'; then
        # Branch is protected, unprotect it
        RESULT=$(curl -s -w "\nHTTP_CODE:%{http_code}" --request DELETE \
            --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
            "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/protected_branches/${BRANCH_NAME}" 2>&1)
        
        HTTP_CODE=$(echo "$RESULT" | grep "HTTP_CODE" | cut -d: -f2)
        if [ "$HTTP_CODE" = "204" ] || [ "$HTTP_CODE" = "200" ]; then
            echo -e "${GREEN}  ✅ Branch unprotected${NC}"
            return 0
        else
            echo -e "${YELLOW}  ⚠️  Response: $HTTP_CODE${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}  ✅ Branch already unprotected${NC}"
        return 0
    fi
}

# Function to merge branch via API
merge_branch() {
    local PROJECT_ID=$1
    local SOURCE_BRANCH=$2
    local TARGET_BRANCH=$3
    
    echo -e "${BLUE}  Merging ${SOURCE_BRANCH} into ${TARGET_BRANCH}...${NC}"
    
    # Create merge request
    MR_DATA=$(curl -s --request POST \
        --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        --header "Content-Type: application/json" \
        --data "{
            \"source_branch\": \"${SOURCE_BRANCH}\",
            \"target_branch\": \"${TARGET_BRANCH}\",
            \"title\": \"Import from GitHub\",
            \"remove_source_branch\": true,
            \"merge_when_pipeline_succeeds\": false,
            \"squash\": false
        }" \
        "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/merge_requests" 2>&1)
    
    MR_ID=$(echo "$MR_DATA" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('iid', '') or d.get('id', ''))" 2>/dev/null)
    
    # Check for error messages
    if echo "$MR_DATA" | grep -q '"message"'; then
        ERROR_MSG=$(echo "$MR_DATA" | python3 -c "import sys, json; print(json.load(sys.stdin).get('message', 'Unknown error'))" 2>/dev/null)
        echo -e "${YELLOW}  ⚠️  MR creation response: $ERROR_MSG${NC}"
    fi
    
    if [ -z "$MR_ID" ] || [ "$MR_ID" = "None" ] || [ "$MR_ID" = "" ]; then
        # MR might already exist, try to find it
        MR_ID=$(curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
            "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/merge_requests?source_branch=${SOURCE_BRANCH}&target_branch=${TARGET_BRANCH}&state=opened" | \
            python3 -c "import sys, json; mr_list=json.load(sys.stdin); print(mr_list[0]['iid'] if mr_list else '')" 2>/dev/null)
        
        if [ -z "$MR_ID" ] || [ "$MR_ID" = "None" ]; then
            echo -e "${YELLOW}  ⚠️  Could not create or find merge request${NC}"
            echo "  Response: $MR_DATA" | head -3
            return 1
        else
            echo -e "${BLUE}  Found existing MR: !${MR_ID}${NC}"
        fi
    else
        echo -e "${BLUE}  Created MR: !${MR_ID}${NC}"
    fi
    
    # Accept/merge the MR
    sleep 2
    MERGE_RESULT=$(curl -s -w "\nHTTP_CODE:%{http_code}" --request PUT \
        --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        --data "merge_commit_message=Merge GitHub import into main" \
        "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/merge_requests/${MR_ID}/merge" 2>&1)
    
    HTTP_CODE=$(echo "$MERGE_RESULT" | grep "HTTP_CODE" | cut -d: -f2)
    
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        echo -e "${GREEN}  ✅ Successfully merged${NC}"
        return 0
    else
        echo -e "${YELLOW}  ⚠️  Merge response: $HTTP_CODE${NC}"
        echo "$MERGE_RESULT" | head -3
        return 1
    fi
}

# Process each project
SUCCESS_COUNT=0
FAILURE_COUNT=0

for PROJECT_PATH in "${PROJECTS[@]}"; do
    echo -e "${CYAN}=== Processing: ${PROJECT_PATH} ===${NC}"
    
    # Get project ID
    PROJECT_ID=$(get_project_id "$PROJECT_PATH")
    
    if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "None" ]; then
        echo -e "${RED}❌ Could not find project ID for ${PROJECT_PATH}${NC}"
        ((FAILURE_COUNT++))
        echo ""
        continue
    fi
    
    echo -e "${BLUE}Project ID: ${PROJECT_ID}${NC}"
    
    # Step 1: Unprotect main branch
    if unprotect_branch "$PROJECT_ID" "main"; then
        sleep 1
        
        # Step 2: Check if github-import-main branch exists
        BRANCHES=$(curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
            "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/repository/branches" 2>&1)
        
        if echo "$BRANCHES" | grep -q "github-import-main"; then
            echo -e "${BLUE}  Found github-import-main branch${NC}"
            
            # Step 3: Merge github-import-main into main
            if merge_branch "$PROJECT_ID" "github-import-main" "main"; then
                echo -e "${GREEN}✅ Successfully completed import for ${PROJECT_PATH}${NC}"
                ((SUCCESS_COUNT++))
            else
                echo -e "${YELLOW}⚠️  Merge failed for ${PROJECT_PATH}${NC}"
                ((FAILURE_COUNT++))
            fi
        else
            echo -e "${YELLOW}  ⚠️  github-import-main branch not found${NC}"
            echo -e "${BLUE}  Attempting direct push to main...${NC}"
            
            # Try to force push directly (branches should be unprotected now)
            echo -e "${YELLOW}  Note: You may need to run the import script again to push to main${NC}"
            ((FAILURE_COUNT++))
        fi
    else
        echo -e "${RED}❌ Failed to unprotect branch for ${PROJECT_PATH}${NC}"
        ((FAILURE_COUNT++))
    fi
    
    echo ""
done

# Summary
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Summary${NC}"
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Successful: ${SUCCESS_COUNT}${NC}"
echo -e "${RED}Failed: ${FAILURE_COUNT}${NC}"
echo ""

if [ $SUCCESS_COUNT -gt 0 ]; then
    echo -e "${GREEN}✅ Import completed! Check GitLab UI to verify.${NC}"
fi


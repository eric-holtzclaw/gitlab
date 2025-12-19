#!/bin/bash
# Simple script to merge github-import-main into main via GitLab API
# Usage: ./scripts/merge-via-api.sh

GITLAB_URL="http://localhost:8080"
GITLAB_TOKEN="glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3"

# Projects to process
PROJECTS=(
    "infrastructure/core"
    "infrastructure/supabase"
    "microsoft-development/o365-forensics-investigator"
    "open-source-development/kali"
)

for PROJECT_PATH in "${PROJECTS[@]}"; do
    echo "=== Processing: $PROJECT_PATH ==="
    
    # Get project ID
    ENCODED_PATH="${PROJECT_PATH//\//%2F}"
    PROJ_ID=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "${GITLAB_URL}/api/v4/projects/${ENCODED_PATH}" | \
        python3 -c "import sys, json; print(json.load(sys.stdin).get('id', ''))" 2>/dev/null)
    
    if [ -z "$PROJ_ID" ] || [ "$PROJ_ID" = "None" ]; then
        echo "  ❌ Could not find project ID"
        continue
    fi
    
    echo "  Project ID: $PROJ_ID"
    
    # Step 1: Unprotect main branch
    echo "  Unprotecting main branch..."
    UNPROTECT_RESULT=$(curl -s -w "\nHTTP_CODE:%{http_code}" --request DELETE \
        --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "${GITLAB_URL}/api/v4/projects/${PROJ_ID}/protected_branches/main" 2>&1)
    HTTP_CODE=$(echo "$UNPROTECT_RESULT" | grep "HTTP_CODE" | cut -d: -f2)
    if [ "$HTTP_CODE" = "204" ] || [ "$HTTP_CODE" = "200" ]; then
        echo "  ✅ Branch unprotected"
    else
        echo "  ⚠️  Branch may already be unprotected (HTTP: $HTTP_CODE)"
    fi
    
    sleep 2
    
    # Step 2: Find or create merge request
    echo "  Finding or creating merge request..."
    MR_LIST=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "${GITLAB_URL}/api/v4/projects/${PROJ_ID}/merge_requests?source_branch=github-import-main&target_branch=main&state=opened")
    
    MR_IID=$(echo "$MR_LIST" | python3 -c "import sys, json; mr_list=json.load(sys.stdin); print(mr_list[0]['iid'] if mr_list and len(mr_list) > 0 else '')" 2>/dev/null)
    
    if [ -z "$MR_IID" ] || [ "$MR_IID" = "None" ]; then
        echo "  Creating new merge request..."
        MR_CREATE=$(curl -s --request POST \
            --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
            --header "Content-Type: application/json" \
            --data '{"source_branch":"github-import-main","target_branch":"main","title":"Import from GitHub"}' \
            "${GITLAB_URL}/api/v4/projects/${PROJ_ID}/merge_requests" 2>&1)
        
        MR_IID=$(echo "$MR_CREATE" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('iid', '') or d.get('id', ''))" 2>/dev/null)
        
        if [ -z "$MR_IID" ] || [ "$MR_IID" = "None" ]; then
            ERROR=$(echo "$MR_CREATE" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('message', 'Unknown error'))" 2>/dev/null)
            echo "  ❌ Failed to create MR: $ERROR"
            continue
        fi
        echo "  ✅ Created MR: !$MR_IID"
    else
        echo "  ✅ Found existing MR: !$MR_IID"
    fi
    
    sleep 2
    
    # Step 3: Merge the MR
    echo "  Merging MR !$MR_IID..."
    MERGE_RESULT=$(curl -s -w "\nHTTP_CODE:%{http_code}" --request PUT \
        --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        --header "Content-Type: application/json" \
        --data '{"merge_commit_message":"Merge GitHub import into main"}' \
        "${GITLAB_URL}/api/v4/projects/${PROJ_ID}/merge_requests/${MR_IID}/merge" 2>&1)
    
    HTTP_CODE=$(echo "$MERGE_RESULT" | grep "HTTP_CODE" | cut -d: -f2)
    MERGE_STATE=$(echo "$MERGE_RESULT" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('state', 'unknown'))" 2>/dev/null)
    
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        echo "  ✅ Successfully merged! State: $MERGE_STATE"
    else
        ERROR=$(echo "$MERGE_RESULT" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('message', 'Unknown error'))" 2>/dev/null)
        echo "  ⚠️  Merge response: HTTP $HTTP_CODE - $ERROR"
    fi
    
    echo ""
done

echo "✅ Done! Check GitLab UI to verify merges."



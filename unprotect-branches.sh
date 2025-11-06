#!/bin/bash
# Unprotect main branches in GitLab projects to allow force push
# Usage: ./unprotect-branches.sh

GITLAB_URL="http://localhost:8080"
GITLAB_TOKEN="glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3"

# Projects to unprotect
PROJECTS=(
    "infrastructure/core"
    "infrastructure/supabase"
    "forensics/O365-Forensics-Investigator"
    "development/kali"
)

echo "Unprotecting main branches in GitLab projects..."
echo ""

for project in "${PROJECTS[@]}"; do
    echo "Unprotecting: $project"
    # Get project ID
    PROJECT_ENCODED="${project//\//%2F}"
    PROJECT_INFO=$(curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        "${GITLAB_URL}/api/v4/projects/${PROJECT_ENCODED}")
    
    PROJECT_ID=$(echo "$PROJECT_INFO" | python3 -c "import sys, json; print(json.load(sys.stdin).get('id', ''))" 2>/dev/null)
    
    if [ -n "$PROJECT_ID" ] && [ "$PROJECT_ID" != "None" ]; then
        echo "  Project ID: $PROJECT_ID"
        
        # Delete protected branch rule (unprotect)
        DELETE_RESULT=$(curl -s --request DELETE \
            --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
            "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/protected_branches/main" 2>&1)
        
        if echo "$DELETE_RESULT" | grep -q "204\|200\|404"; then
            echo "  ✅ Unprotected main branch"
        else
            echo "  ⚠️  Response: $DELETE_RESULT"
        fi
    else
        echo "  ❌ Could not find project ID"
        echo "  Response: $PROJECT_INFO"
    fi
    echo ""
done

echo "Done! You can now run the import script again."


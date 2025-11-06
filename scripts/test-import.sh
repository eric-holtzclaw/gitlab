#!/bin/bash
# Simple test script that writes to a file
set -e

OUTPUT_FILE="/tmp/gitlab-import-test.log"

echo "=== GitLab Import Test ===" > "$OUTPUT_FILE"
echo "Date: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Test 1: Port-forward
echo "Test 1: Checking port-forward..." >> "$OUTPUT_FILE"
if lsof -i :8080 > /dev/null 2>&1; then
    echo "✅ Port-forward is running" >> "$OUTPUT_FILE"
    lsof -i :8080 | head -2 >> "$OUTPUT_FILE"
else
    echo "❌ Port-forward is NOT running" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# Test 2: GitLab API
echo "Test 2: Testing GitLab API..." >> "$OUTPUT_FILE"
API_TEST=$(curl -s -w "\nHTTP_CODE:%{http_code}" -u "root:ChangeMe123!@#SecurePassword" "http://localhost:8080/api/v4/user" 2>&1)
echo "$API_TEST" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Test 3: Clone core repository
echo "Test 3: Cloning core repository..." >> "$OUTPUT_FILE"
cd /tmp
rm -rf test-core-import.git 2>/dev/null
if git clone --mirror https://github.com/eric-holtzclaw/core.git test-core-import.git 2>&1 | tee -a "$OUTPUT_FILE"; then
    echo "✅ Clone successful" >> "$OUTPUT_FILE"
    cd test-core-import.git
    COMMITS=$(git rev-list --all --count 2>/dev/null || echo "0")
    echo "Repository has $COMMITS commits" >> "$OUTPUT_FILE"
    
    # Test 4: Push to GitLab
    echo "" >> "$OUTPUT_FILE"
    echo "Test 4: Pushing to GitLab..." >> "$OUTPUT_FILE"
    GIT_URL="http://root:ChangeMe123!@#SecurePassword@localhost:8080/infrastructure/core.git"
    git push --mirror "$GIT_URL" 2>&1 | tee -a "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "Push command completed" >> "$OUTPUT_FILE"
    
    cd /tmp
    rm -rf test-core-import.git
else
    echo "❌ Clone failed" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"
echo "=== Test Complete ===" >> "$OUTPUT_FILE"
echo "Results saved to: $OUTPUT_FILE"
cat "$OUTPUT_FILE"



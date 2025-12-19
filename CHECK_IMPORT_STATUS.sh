#!/bin/bash
# Quick script to check import status
# Usage: ./CHECK_IMPORT_STATUS.sh

echo "=== GitLab Import Status Check ==="
echo ""

# Check if log exists
if [ -f /tmp/gitlab-import-run.log ]; then
    echo "✅ Log file exists"
    echo "Lines: $(wc -l < /tmp/gitlab-import-run.log)"
    echo ""
    echo "--- Last 30 lines ---"
    tail -30 /tmp/gitlab-import-run.log
    echo ""
else
    echo "❌ Log file does NOT exist"
    echo "   Script may not have run yet"
    echo ""
fi

# Check if script is running
if ps aux | grep -q "[r]un-import"; then
    echo "✅ Script is currently running"
    ps aux | grep "[r]un-import" | grep -v grep
else
    echo "❌ Script is NOT running"
fi

echo ""
echo "=== Port-Forward Status ==="
if lsof -i :8080 > /dev/null 2>&1; then
    echo "✅ Port-forward is running"
    lsof -i :8080 | head -2
else
    echo "❌ Port-forward is NOT running"
    echo "   Run: kubectl port-forward -n gitlab service/gitlab-service 8080:80"
fi

echo ""
echo "=== To Run Import ==="
echo "cd /Users/eric/Documents/Scripts/infrastructure/gitlab"
echo "./scripts/run-import.sh"




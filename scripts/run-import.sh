#!/bin/bash
# Simple Import Script - Writes output to log file
# Usage: ./scripts/run-import.sh
# 
# Authentication methods (in order of preference):
# 1. SSH (if SSH keys are configured with GitHub)
# 2. GITHUB_TOKEN environment variable (for HTTPS)
# 3. HTTPS without auth (will fail for private repos)

LOG_FILE="/tmp/gitlab-import-run.log"
GITLAB_TOKEN="glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3"

# Initialize log file
echo "=== GitLab Repository Import ===" > "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Ensure GitLab port-forward is running
echo "Checking GitLab port-forward..." | tee -a "$LOG_FILE"
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo "Starting GitLab port-forward..." | tee -a "$LOG_FILE"
    pkill -f "kubectl port-forward.*gitlab" 2>/dev/null
    kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /tmp/gitlab-port-forward.log 2>&1 &
    sleep 5
    if lsof -i :8080 > /dev/null 2>&1; then
        echo "✅ Port-forward started" | tee -a "$LOG_FILE"
    else
        echo "❌ Port-forward failed to start!" | tee -a "$LOG_FILE"
        echo "Check: kubectl get pods -n gitlab" | tee -a "$LOG_FILE"
        exit 1
    fi
else
    echo "✅ Port-forward already running" | tee -a "$LOG_FILE"
fi
echo "" >> "$LOG_FILE"

# Check if SSH works with GitHub
USE_SSH=false
echo "Testing SSH connection to GitHub..." | tee -a "$LOG_FILE"
SSH_TEST=$(ssh -T git@github.com 2>&1)
echo "SSH test output: $SSH_TEST" >> "$LOG_FILE"

if echo "$SSH_TEST" | grep -q "successfully authenticated\|Hi.*You've successfully authenticated"; then
    USE_SSH=true
    echo "✅ Using SSH for GitHub authentication" | tee -a "$LOG_FILE"
elif [ -n "$GITHUB_TOKEN" ]; then
    echo "✅ Using GitHub Personal Access Token for authentication" | tee -a "$LOG_FILE"
else
    echo "⚠️  WARNING: No GitHub authentication method found." | tee -a "$LOG_FILE"
    echo "   SSH test output: $SSH_TEST" | tee -a "$LOG_FILE"
    echo "   Options:" | tee -a "$LOG_FILE"
    echo "   1. Set up SSH keys with GitHub (recommended)" | tee -a "$LOG_FILE"
    echo "   2. Set GITHUB_TOKEN environment variable" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
fi
echo "" >> "$LOG_FILE"

import_one() {
    local GITHUB=$1
    local GROUP=$2
    local NAME=$3
    
    echo "Importing $NAME..." | tee -a "$LOG_FILE"
    
    TEMP=$(mktemp -d)
    cd "$TEMP"
    
    # Convert HTTPS URL to SSH URL if using SSH
    if [ "$USE_SSH" = true ]; then
        # Convert: https://github.com/user/repo.git -> git@github.com:user/repo.git
        GITHUB_URL=$(echo "$GITHUB" | sed 's|https://github.com/|git@github.com:|')
        git clone --mirror "$GITHUB_URL" "${NAME}.git" >> "$LOG_FILE" 2>&1
    elif [ -n "$GITHUB_TOKEN" ]; then
        # Use GitHub token for HTTPS
        GITHUB_AUTH_URL=$(echo "$GITHUB" | sed "s|https://github.com|https://${GITHUB_TOKEN}@github.com|")
        git clone --mirror "$GITHUB_AUTH_URL" "${NAME}.git" >> "$LOG_FILE" 2>&1
    else
        # Try HTTPS without auth (will fail for private repos)
        git clone --mirror "$GITHUB" "${NAME}.git" >> "$LOG_FILE" 2>&1
    fi
    if [ $? -eq 0 ]; then
        cd "${NAME}.git"
        COMMITS=$(git rev-list --all --count 2>/dev/null || echo "0")
        echo "  ✅ Cloned: $COMMITS commits" | tee -a "$LOG_FILE"
        
        # Skip push if repository is empty (like gitlab repo)
        if [ "$COMMITS" -eq 0 ]; then
            echo "  ⚠️  Skipping push: repository is empty" | tee -a "$LOG_FILE"
        else
            # Try SSH first (best practice - no credentials needed)
            echo "  Attempting SSH push (best practice)..." | tee -a "$LOG_FILE"
            git push --mirror --force "ssh://git@localhost:2222/${GROUP}/${NAME}.git" >> "$LOG_FILE" 2>&1
            if [ $? -eq 0 ]; then
                echo "  ✅ Pushed successfully via SSH" | tee -a "$LOG_FILE"
            else
                # Fallback to HTTP with token if SSH fails
                echo "  ⚠️  SSH push failed, trying HTTP with token..." | tee -a "$LOG_FILE"
                git push --mirror --force "http://oauth2:${GITLAB_TOKEN}@localhost:8080/${GROUP}/${NAME}.git" >> "$LOG_FILE" 2>&1
                if [ $? -eq 0 ]; then
                    echo "  ✅ Pushed successfully via HTTP" | tee -a "$LOG_FILE"
                else
                    # If force push fails, try pushing to a temporary branch first
                    echo "  ⚠️  Force push failed, trying temporary branch approach..." | tee -a "$LOG_FILE"
                    # Push all branches and tags to temp branch first
                    git push --all "http://oauth2:${GITLAB_TOKEN}@localhost:8080/${GROUP}/${NAME}.git" >> "$LOG_FILE" 2>&1
                    git push --tags "http://oauth2:${GITLAB_TOKEN}@localhost:8080/${GROUP}/${NAME}.git" >> "$LOG_FILE" 2>&1
                    
                    # Try to push main to a temp branch
                    if git show-ref --verify --quiet refs/heads/main; then
                        echo "  Attempting to push main to temp branch..." | tee -a "$LOG_FILE"
                        git push "http://oauth2:${GITLAB_TOKEN}@localhost:8080/${GROUP}/${NAME}.git" main:github-import-main >> "$LOG_FILE" 2>&1
                        if [ $? -eq 0 ]; then
                            echo "  ✅ Pushed to github-import-main branch. You can merge this into main via GitLab UI." | tee -a "$LOG_FILE"
                        fi
                    fi
                    echo "  ⚠️  Note: Main branch is protected. Content pushed to github-import-main branch." | tee -a "$LOG_FILE"
                fi
            fi
        fi
        cd "$TEMP"
        rm -rf "${NAME}.git"
    else
        echo "  ❌ Clone failed - check $LOG_FILE" | tee -a "$LOG_FILE"
    fi
    
    rm -rf "$TEMP"
    echo "" | tee -a "$LOG_FILE"
}

# Import all repositories
echo "=== Infrastructure Group ===" | tee -a "$LOG_FILE"
import_one "https://github.com/eric-holtzclaw/core.git" "infrastructure" "core"
import_one "https://github.com/eric-holtzclaw/supabase.git" "infrastructure" "supabase"
import_one "https://github.com/eric-holtzclaw/Nginx.git" "infrastructure" "nginx"

echo "=== Applications Group ===" | tee -a "$LOG_FILE"
import_one "https://github.com/eric-holtzclaw/gitlab.git" "applications" "gitlab"
import_one "https://github.com/eric-holtzclaw/gmaxgolfapp.git" "applications" "gmaxgolfapp"
import_one "https://github.com/eric-holtzclaw/health-app.git" "applications" "health-app"

echo "=== Microsoft Development Group ===" | tee -a "$LOG_FILE"
import_one "https://github.com/eric-holtzclaw/O365-Forensics-Investigator.git" "microsoft-development" "O365-Forensics-Investigator"

echo "=== Open Source Development Group ===" | tee -a "$LOG_FILE"
import_one "https://github.com/eric-holtzclaw/kali.git" "open-source-development" "kali"
import_one "https://github.com/eric-holtzclaw/browser-lockdown.git" "open-source-development" "browser-lockdown"
import_one "https://github.com/eric-holtzclaw/unified-wifi-scanner.git" "open-source-development" "unified-wifi-scanner"
import_one "https://github.com/eric-holtzclaw/Google-Workspace-Forensics-Investigator.git" "open-source-development" "google-workspace-forensics-investigator"

echo "=== Automation Group ===" | tee -a "$LOG_FILE"
import_one "https://github.com/eric-holtzclaw/N8N.git" "automation" "N8N"

echo "=== Open Source Development Group ===" | tee -a "$LOG_FILE"
import_one "https://github.com/eric-holtzclaw/kali.git" "open-source-development" "kali"
import_one "https://github.com/eric-holtzclaw/browser-lockdown.git" "open-source-development" "browser-lockdown"
import_one "https://github.com/eric-holtzclaw/unified-wifi-scanner.git" "open-source-development" "unified-wifi-scanner"

echo "=== Import Complete ===" >> "$LOG_FILE"
echo "Finished: $(date)" >> "$LOG_FILE"
echo ""
echo "Log file: $LOG_FILE"
cat "$LOG_FILE"

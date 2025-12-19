#!/bin/bash
# Simple script to add SSH key to GitLab
# Usage: ./scripts/add-ssh-key-simple.sh

GITLAB_URL="http://localhost:8080"
GITLAB_TOKEN="glpat-Bn5Gr8ecMVFUP3B4aCBVtW86MQp1OjEH.01.0w0baopj3"

echo "=== Adding SSH Key to GitLab ==="
echo ""

# Find SSH key
if [ -f ~/.ssh/id_ed25519.pub ]; then
    SSH_KEY_FILE=~/.ssh/id_ed25519.pub
elif [ -f ~/.ssh/id_rsa.pub ]; then
    SSH_KEY_FILE=~/.ssh/id_rsa.pub
else
    echo "❌ No SSH public key found!"
    echo "Generate one with: ssh-keygen -t ed25519 -C 'your_email@example.com'"
    exit 1
fi

echo "Found SSH key: $SSH_KEY_FILE"
SSH_KEY=$(cat "$SSH_KEY_FILE")
KEY_TITLE="$(hostname)-$(date +%Y%m%d)"

echo "Adding key: $KEY_TITLE"
echo ""

# Add to GitLab
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" --request POST \
    --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    --header "Content-Type: application/json" \
    --data "{\"title\":\"${KEY_TITLE}\",\"key\":\"${SSH_KEY}\"}" \
    "${GITLAB_URL}/api/v4/user/keys" 2>&1)

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE")

if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    echo "✅ SSH key added successfully!"
    echo "$BODY" | python3 -c "import sys, json; d=json.load(sys.stdin); print(f\"Key ID: {d.get('id', 'N/A')}\"); print(f\"Title: {d.get('title', 'N/A')}\"); print(f\"Created: {d.get('created_at', 'N/A')}\")" 2>/dev/null
elif echo "$BODY" | grep -q "has already been taken"; then
    echo "⚠️  SSH key already exists in GitLab"
    echo "✅ Using existing key"
else
    echo "❌ Failed to add SSH key (HTTP $HTTP_CODE)"
    echo "$BODY" | head -5
    exit 1
fi

echo ""
echo "✅ SSH key setup complete!"
echo ""
echo "To test SSH connection:"
echo "  1. Start SSH port-forward: kubectl port-forward -n gitlab service/gitlab-service 2222:2222"
echo "  2. Test: ssh -T -p 2222 git@localhost"
echo ""




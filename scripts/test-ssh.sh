#!/bin/bash
# Quick test to verify SSH works with GitHub

echo "Testing SSH connection to GitHub..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "✅ SSH works with GitHub!"
    exit 0
else
    echo "❌ SSH test output:"
    ssh -T git@github.com 2>&1
    exit 1
fi




#!/bin/bash
# Automated GitLab backup
# Creates a backup of GitLab data and configuration

set -e

BACKUP_DIR="${GITLAB_BACKUP_DIR:-/tmp/gitlab-backups}"
DATE=$(date +%Y%m%d_%H%M%S)
NAMESPACE="gitlab"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== GitLab Backup ===${NC}"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"
echo -e "${GREEN}✅ Backup directory: ${BACKUP_DIR}${NC}"

# Get GitLab pod name
POD_NAME=$(kubectl get pods -n "$NAMESPACE" -l app=gitlab -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -z "$POD_NAME" ]; then
    echo -e "${YELLOW}⚠️  GitLab pod not found. Is GitLab running?${NC}"
    exit 1
fi

echo "GitLab pod: $POD_NAME"
echo ""

# Create backup inside the pod
echo -e "${BLUE}Creating backup in GitLab pod...${NC}"
kubectl exec -n "$NAMESPACE" "$POD_NAME" -- \
    gitlab-backup create BACKUP=dump_${DATE} 2>&1 | tee /tmp/gitlab-backup-${DATE}.log

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "${GREEN}✅ Backup created successfully${NC}"
else
    echo -e "${YELLOW}⚠️  Backup may have completed with warnings. Check logs.${NC}"
fi

echo ""

# Copy backup from pod
echo -e "${BLUE}Copying backup from pod...${NC}"
BACKUP_FILE="dump_${DATE}_gitlab_backup.tar"

if kubectl cp "${NAMESPACE}/${POD_NAME}:/var/opt/gitlab/backups/${BACKUP_FILE}" \
    "${BACKUP_DIR}/${BACKUP_FILE}" 2>/dev/null; then
    echo -e "${GREEN}✅ Backup copied to: ${BACKUP_DIR}/${BACKUP_FILE}${NC}"
    
    # Get file size
    FILE_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_FILE}" | cut -f1)
    echo "   Size: $FILE_SIZE"
else
    echo -e "${YELLOW}⚠️  Could not copy backup file. It may be in the pod at:${NC}"
    echo "   /var/opt/gitlab/backups/${BACKUP_FILE}"
    echo ""
    echo "To copy manually:"
    echo "  kubectl cp ${NAMESPACE}/${POD_NAME}:/var/opt/gitlab/backups/${BACKUP_FILE} ${BACKUP_DIR}/${BACKUP_FILE}"
fi

echo ""
echo -e "${BLUE}=== Backup Complete ===${NC}"
echo ""
echo "Backup location: ${BACKUP_DIR}/${BACKUP_FILE}"
echo ""
echo "To restore:"
echo "  1. Copy backup to pod: kubectl cp ${BACKUP_DIR}/${BACKUP_FILE} ${NAMESPACE}/${POD_NAME}:/var/opt/gitlab/backups/"
echo "  2. Restore: kubectl exec -n ${NAMESPACE} ${POD_NAME} -- gitlab-backup restore BACKUP=dump_${DATE}"



#!/bin/bash
# Database Backup Script for PostgreSQL
# This script creates a backup of the PostgreSQL database

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
POSTGRES_POD=$(kubectl get pods -n default -l app.kubernetes.io/name=postgresql -o jsonpath='{.items[0].metadata.name}')
BACKUP_DIR="/tmp/backups"
BACKUP_FILE="reliops_db_$(date +%Y%m%d_%H%M%S).sql"
RETENTION_DAYS=7

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

log_info "Starting database backup..."
log_info "PostgreSQL pod: $POSTGRES_POD"

# Perform backup using pg_dump
log_info "Creating backup file: $BACKUP_FILE"
kubectl exec -n default $POSTGRES_POD -- pg_dump \
    -U reliops \
    -d reliops_db \
    -F c \
    -f "/tmp/$BACKUP_FILE"

# Copy backup file from pod to local
log_info "Copying backup file from pod..."
kubectl cp default/$POSTGRES_POD:/tmp/$BACKUP_FILE $BACKUP_DIR/$BACKUP_FILE

# Verify backup file exists
if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)
    log_success "Backup completed successfully: $BACKUP_FILE (Size: $BACKUP_SIZE)"
else
    log_error "Backup file not found!"
    exit 1
fi

# Clean up old backups
log_info "Cleaning up backups older than $RETENTION_DAYS days..."
find $BACKUP_DIR -name "reliops_db_*.sql" -type f -mtime +$RETENTION_DAYS -delete

# List current backups
log_info "Current backups:"
ls -lh $BACKUP_DIR/reliops_db_*.sql 2>/dev/null || echo "No backups found"

log_success "Backup process completed!"

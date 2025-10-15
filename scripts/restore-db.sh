#!/bin/bash
# Database Restore Script for PostgreSQL
# This script restores a PostgreSQL database from backup

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

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if backup file is provided
if [ -z "$1" ]; then
    log_error "No backup file specified!"
    echo "Usage: $0 <backup_file>"
    echo ""
    echo "Available backups:"
    ls -1 $BACKUP_DIR/reliops_db_*.sql 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_FILE=$1

# Verify backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    log_error "Backup file not found: $BACKUP_FILE"
    exit 1
fi

log_warning "This will restore the database from: $BACKUP_FILE"
log_warning "ALL CURRENT DATA WILL BE REPLACED!"
read -p "Are you sure you want to continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    log_info "Restore cancelled"
    exit 0
fi

log_info "Starting database restore..."
log_info "PostgreSQL pod: $POSTGRES_POD"

# Copy backup file to pod
BACKUP_FILENAME=$(basename $BACKUP_FILE)
log_info "Copying backup file to pod..."
kubectl cp $BACKUP_FILE default/$POSTGRES_POD:/tmp/$BACKUP_FILENAME

# Drop existing connections
log_info "Terminating existing connections..."
kubectl exec -n default $POSTGRES_POD -- psql -U postgres -c \
    "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='reliops_db' AND pid <> pg_backend_pid();"

# Drop and recreate database
log_info "Recreating database..."
kubectl exec -n default $POSTGRES_POD -- psql -U postgres -c "DROP DATABASE IF EXISTS reliops_db;"
kubectl exec -n default $POSTGRES_POD -- psql -U postgres -c "CREATE DATABASE reliops_db OWNER reliops;"

# Restore from backup
log_info "Restoring from backup..."
kubectl exec -n default $POSTGRES_POD -- pg_restore \
    -U reliops \
    -d reliops_db \
    -v \
    /tmp/$BACKUP_FILENAME

# Verify restore
log_info "Verifying restore..."
TABLE_COUNT=$(kubectl exec -n default $POSTGRES_POD -- psql -U reliops -d reliops_db -t -c \
    "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';")

log_success "Restore completed successfully!"
log_info "Tables restored: $TABLE_COUNT"

# Clean up temporary file from pod
kubectl exec -n default $POSTGRES_POD -- rm /tmp/$BACKUP_FILENAME

log_success "Database restore process completed!"

#!/bin/bash

# Database Update Script Runner
# This script helps execute the database schema updates

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_SCRIPT="$SCRIPT_DIR/../update-schema.sql"
BACKUP_DIR="$SCRIPT_DIR/../backups"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if PostgreSQL is available
check_postgres() {
    if ! command -v psql &> /dev/null; then
        print_error "PostgreSQL client (psql) is not installed or not in PATH"
        exit 1
    fi
    print_success "PostgreSQL client found"
}

# Function to backup current database
create_backup() {
    print_info "Creating database backup..."

    mkdir -p "$BACKUP_DIR"

    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="$BACKUP_DIR/backup_before_update_$timestamp.sql"

    # Get database connection details from environment
    local db_url="${DATABASE_URL:-postgresql://postgres:postgres@localhost:5432/school_mgmt}"

    # Extract connection details from URL
    local db_host=$(echo "$db_url" | sed -n 's|.*@\([^:]*\):.*|\1|p')
    local db_port=$(echo "$db_url" | sed -n 's|.*:\([0-9]*\)/.*|\1|p')
    local db_name=$(echo "$db_url" | sed -n 's|.*/\([^?]*\).*|\1|p')
    local db_user=$(echo "$db_url" | sed -n 's|.*://\([^:]*\):.*|\1|p')

    # Create backup
    if pg_dump -h "$db_host" -p "$db_port" -U "$db_user" -d "$db_name" -f "$backup_file" --no-password; then
        print_success "Backup created: $backup_file"
        echo "$backup_file" > "$SCRIPT_DIR/.last_backup"
    else
        print_error "Failed to create backup"
        exit 1
    fi
}

# Function to execute the update script
run_update() {
    print_info "Executing database update script..."

    # Get database connection details
    local db_url="${DATABASE_URL:-postgresql://postgres:postgres@localhost:5432/school_mgmt}"

    # Execute the update script
    if psql "$db_url" -f "$UPDATE_SCRIPT" --quiet; then
        print_success "Database update completed successfully!"
    else
        print_error "Database update failed!"
        exit 1
    fi
}

# Function to verify the update
verify_update() {
    print_info "Verifying database update..."

    local db_url="${DATABASE_URL:-postgresql://postgres:postgres@localhost:5432/school_mgmt}"

    # Test some of the new functions/views
    local test_queries="
        SELECT 'Health Check' as test, COUNT(*) as result FROM database_health_check();
        SELECT 'User Statistics' as test, total_users as result FROM get_user_statistics();
        SELECT 'Views Exist' as test, COUNT(*) as result FROM information_schema.views WHERE table_name IN ('active_students', 'active_teachers', 'recent_notices');
        SELECT 'Indexes Created' as test, COUNT(*) as result FROM pg_indexes WHERE indexname LIKE 'idx_%';
    "

    if psql "$db_url" -c "$test_queries" --quiet; then
        print_success "Database verification completed successfully!"
    else
        print_warning "Some verification checks failed, but update may still be successful"
    fi
}

# Function to show help
show_help() {
    cat << EOF
Database Update Script Runner

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    -b, --backup-only   Only create backup, don't run update
    -u, --update-only   Only run update, don't create backup (not recommended)
    -v, --verify-only   Only run verification checks
    --no-backup         Run update without backup (not recommended)
    --dry-run           Show what would be done without executing

ENVIRONMENT VARIABLES:
    DATABASE_URL        PostgreSQL connection string
                       Default: postgresql://postgres:postgres@localhost:5432/school_mgmt

EXAMPLES:
    $0                          # Full update with backup
    $0 --no-backup             # Update without backup (dangerous)
    $0 --backup-only           # Only create backup
    $0 --dry-run               # Show what would happen

BACKUP LOCATION:
    Backups are stored in: $BACKUP_DIR
    Last backup info: $SCRIPT_DIR/.last_backup

EOF
}

# Main execution
main() {
    local backup_only=false
    local update_only=false
    local verify_only=false
    local no_backup=false
    local dry_run=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -b|--backup-only)
                backup_only=true
                ;;
            -u|--update-only)
                update_only=true
                ;;
            -v|--verify-only)
                verify_only=true
                ;;
            --no-backup)
                no_backup=true
                ;;
            --dry-run)
                dry_run=true
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done

    print_info "Database Update Script Runner"
    print_info "============================="

    # Check prerequisites
    check_postgres

    # Dry run mode
    if [[ "$dry_run" == true ]]; then
        print_info "DRY RUN MODE - No actual changes will be made"
        echo
        echo "Would perform the following actions:"
        echo "1. Check PostgreSQL connection"
        echo "2. Create database backup"
        echo "3. Execute schema updates from: $UPDATE_SCRIPT"
        echo "4. Verify the changes"
        echo
        echo "Database URL: ${DATABASE_URL:-postgresql://postgres:postgres@localhost:5432/school_mgmt}"
        echo "Backup location: $BACKUP_DIR"
        exit 0
    fi

    # Execute based on options
    if [[ "$backup_only" == true ]]; then
        create_backup
        exit 0
    fi

    if [[ "$verify_only" == true ]]; then
        verify_update
        exit 0
    fi

    # Default behavior: backup + update + verify
    if [[ "$no_backup" == false && "$update_only" == false ]]; then
        create_backup
    fi

    if [[ "$backup_only" == false ]]; then
        run_update
        verify_update
    fi

    print_success "All operations completed successfully!"
    print_info "Check the README-updates.md file for more information about the changes."
}

# Run main function
main "$@"

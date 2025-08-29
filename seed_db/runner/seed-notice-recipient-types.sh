#!/bin/bash

# Seed Notice Recipient Types Script Runner
# This script helps seed notice recipient types for role-based notice targeting

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEED_SCRIPT="$SCRIPT_DIR/../seed-notice-recipient-types.sql"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function to check if PostgreSQL is available
check_postgres() {
    if ! command -v psql &> /dev/null; then        echo "❌ PostgreSQL client (psql) is not installed or not in PATH"
        exit 1
    fi
    print_success "PostgreSQL client found"
}

# Function to run the seed script
seed_recipient_types() {
    print_info "Seeding notice recipient types..."

    # Get database connection details
    local db_url="${DATABASE_URL:-postgresql://postgres:postgres@localhost:5432/school_mgmt}"

    # Execute the seed script
    if psql "$db_url" -f "$SEED_SCRIPT" --quiet; then
        print_success "Notice recipient types seeded successfully!"
        echo ""
        echo "🎯 What's been configured:"
        echo "   • Students: Class and Section selectors"
        echo "   • Teachers: Department selector"
        echo "   • Staff: Department selector"
        echo "   • Admins: Full access (no additional selectors)"
        echo ""
        echo "📋 This enables:"
        echo "   • Targeted notice delivery to specific groups"
        echo "   • Class/section-based student notifications"
        echo "   • Department-based staff notifications"
        echo "   • Flexible recipient selection"
    else
        echo "❌ Failed to seed notice recipient types"
        exit 1
    fi
}

# Function to verify the seeding
verify_seeding() {
    print_info "Verifying notice recipient types..."

    local db_url="${DATABASE_URL:-postgresql://postgres:5432/school_mgmt}"

    # Test queries to verify data exists
    local test_queries="
        SELECT 'Recipient Types Created' as check_type, COUNT(*) as count FROM notice_recipient_types;
        SELECT 'Student Selectors' as check_type, COUNT(*) as count FROM notice_recipient_types WHERE role_id = 3;
        SELECT 'Teacher Selectors' as check_type, COUNT(*) as count FROM notice_recipient_types WHERE role_id = 2;
    "

    if psql "$db_url" -c "$test_queries" --quiet; then
        print_success "Notice recipient types verification completed!"
    else
        echo "⚠️  Some verification checks failed, but seeding may still be successful"
    fi
}

# Main execution
main() {
    print_info "School Management System - Notice Recipient Types Seeding"
    print_info "=========================================================="

    # Check prerequisites
    check_postgres

    # Seed the data
    seed_recipient_types

    # Verify the seeding
    verify_seeding
}

# Run main function
main "$@"

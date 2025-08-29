#!/bin/bash

# Seed Roles Script Runner
# This script helps seed essential roles and sample data for the school management system

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEED_SCRIPT="$SCRIPT_DIR/../seed-roles.sql"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function to check if PostgreSQL is available
check_postgres() {
    if ! command -v psql &> /dev/null; then
        echo "❌ PostgreSQL client (psql) is not installed or not in PATH"
        exit 1
    fi
    print_success "PostgreSQL client found"
}

# Function to run the seed script
seed_roles() {
    print_info "Seeding roles and sample data..."

    # Get database connection details
    local db_url="${DATABASE_URL:-postgresql://postgres:postgres@localhost:5432/school_mgmt}"

    # Execute the seed script
    if psql "$db_url" -f "$SEED_SCRIPT" --quiet; then
        print_success "Roles and sample data seeded successfully!"
        echo ""
        echo "📋 What's been created:"
        echo "   • 5 Roles: Admin, Teacher, Student, Staff, Parent"
        echo "   • Sample users with profiles"
        echo "   • Classes (1-5) with sections (A, B, C)"
        echo "   • Departments and notice statuses"
        echo "   • Role-based permissions"
        echo ""
        echo "🎯 You can now:"
        echo "   • Create notices for specific roles"
        echo "   • Use role-based recipient selection"
        echo "   • Test the complete notice workflow"
    else
        echo "❌ Failed to seed roles and data"
        exit 1
    fi
}

# Function to verify the seeding
verify_seeding() {
    print_info "Verifying seeded data..."

    local db_url="${DATABASE_URL:-postgresql://postgres:postgres@localhost:5432/school_mgmt}"

    # Test queries to verify data exists
    local test_queries="
        SELECT 'Roles Created' as check_type, COUNT(*) as count FROM roles;
        SELECT 'Users Created' as check_type, COUNT(*) as count FROM users;
        SELECT 'Classes Created' as check_type, COUNT(*) as count FROM classes;
        SELECT 'Permissions Set' as check_type, COUNT(*) as count FROM permissions;
    "

    if psql "$db_url" -c "$test_queries" --quiet; then
        print_success "Data verification completed!"
    else
        echo "⚠️  Some verification checks failed, but seeding may still be successful"
    fi
}

# Main execution
main() {
    print_info "School Management System - Role Seeding"
    print_info "======================================"

    # Check prerequisites
    check_postgres

    # Seed the data
    seed_roles

    # Verify the seeding
    verify_seeding

    print_success "Seeding process completed!"
}

# Run main function
main "$@"

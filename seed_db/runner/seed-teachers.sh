#!/bin/bash

# Seed Teachers Script Runner
# This script helps seed sample teachers with complete profiles

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEED_SCRIPT="$SCRIPT_DIR/../seed-teachers.sql"

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
seed_teachers() {
    print_info "Seeding sample teachers..."

    # Get database connection details
    local db_url="${DATABASE_URL:-postgresql://postgres:postgres@localhost:5432/school_mgmt}"

    # Execute the seed script
    if psql "$db_url" -f "$SEED_SCRIPT" --quiet; then
        print_success "Teachers seeded successfully!"
        echo ""
        echo "👨‍🏫 What's been created:"
        echo "   • 15 qualified teachers with diverse backgrounds"
        echo "   • Complete teacher profiles with qualifications"
        echo "   • Department assignments (Math, Science, English, etc.)"
        echo "   • Experience levels (3-10+ years)"
        echo "   • Professional titles (Dr., Prof., Mr., Mrs., Ms.)"
        echo ""
        echo "📊 Teacher distribution:"
        echo "   • Multiple departments covered"
        echo "   • Balanced gender distribution"
        echo "   • Various experience levels"
        echo "   • Realistic qualifications"
        echo ""
        echo "📋 Profile details include:"
        echo "   • Professional information (name, title, department)"
        echo "   • Academic qualifications (Ph.D., M.Ed., B.Ed., etc.)"
        echo "   • Work experience (years of teaching)"
        echo "   • Contact details and personal information"
        echo "   • Employment dates and history"
        echo ""
        echo "🎯 Qualification mix:"
        echo "   • Ph.D. in Education"
        echo "   • M.Ed. (Masters in Education)"
        echo "   • B.Ed. with subject specialization"
        echo "   • M.A. in Education"
    else
        echo "❌ Failed to seed teachers"
        exit 1
    fi
}

# Function to verify the seeding
verify_seeding() {
    print_info "Verifying teacher data..."

    local db_url="${DATABASE_URL:-postgresql://postgres:5432/school_mgmt}"

    # Test queries to verify data exists
    local test_queries="
        SELECT 'Teachers Created' as check_type, COUNT(*) as count FROM users WHERE role_id = 2;
        SELECT 'Teacher Profiles' as check_type, COUNT(*) as count FROM user_profiles up JOIN users u ON up.user_id = u.id WHERE u.role_id = 2;
        SELECT 'Departments Assigned' as check_type, COUNT(DISTINCT department_id) as count FROM user_profiles up JOIN users u ON up.user_id = u.id WHERE u.role_id = 2 AND department_id IS NOT NULL;
        SELECT 'Active Teachers' as check_type, COUNT(*) as count FROM users WHERE role_id = 2 AND is_active = true;
    "

    if psql "$db_url" -c "$test_queries" --quiet; then
        print_success "Teacher data verification completed!"
    else
        echo "⚠️  Some verification checks failed, but seeding may still be successful"
    fi
}

# Main execution
main() {
    print_info "School Management System - Teachers Seeding"
    print_info "=========================================="

    # Check prerequisites
    check_postgres

    # Seed the data
    seed_teachers

    # Verify the seeding
    verify_seeding

    print_success "Teachers seeding process completed!"

# Run main function
main "$@"

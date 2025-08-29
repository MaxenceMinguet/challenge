#!/bin/bash

# Seed Students Script Runner
# This script helps seed sample students with complete profiles

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEED_SCRIPT="$SCRIPT_DIR/../seed-students.sql"

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
seed_students() {
    print_info "Seeding sample students..."

    # Get database connection details
    local db_url="${DATABASE_URL:-postgresql://postgres:postgres@localhost:5432/school_mgmt}"

    # Execute the seed script
    if psql "$db_url" -f "$SEED_SCRIPT" --quiet; then
        print_success "Students seeded successfully!"
        echo ""
        echo "🎓 What's been created:"
        echo "   • 20 sample students with unique email addresses"
        echo "   • Complete student profiles with academic details"
        echo "   • Class and section assignments"
        echo "   • Parent contact information"
        echo "   • Admission and enrollment dates"
        echo ""
        echo "📊 Student distribution:"
        echo "   • Classes 1-3 covered"
        echo "   • Sections A, B, C assigned"
        echo "   • Balanced gender distribution"
        echo "   • Realistic Indian names and addresses"
        echo ""
        echo "📋 Profile details include:"
        echo "   • Personal information (name, DOB, gender)"
        echo "   • Contact details (phone, email)"
        echo "   • Academic info (class, section, roll number)"
        echo "   • Family details (parents' names and phones)"
        echo "   • Address information"
        echo "   • Admission records"
    else
        echo "❌ Failed to seed students"
        exit 1
    fi
}

# Function to verify the seeding
verify_seeding() {
    print_info "Verifying student data..."

    local db_url="${DATABASE_URL:-postgresql://postgres:5432/school_mgmt}"

    # Test queries to verify data exists
    local test_queries="
        SELECT 'Students Created' as check_type, COUNT(*) as count FROM users WHERE role_id = 3;
        SELECT 'Student Profiles' as check_type, COUNT(*) as count FROM user_profiles up JOIN users u ON up.user_id = u.id WHERE u.role_id = 3;
        SELECT 'Classes Assigned' as check_type, COUNT(DISTINCT class_name) as count FROM user_profiles up JOIN users u ON up.user_id = u.id WHERE u.role_id = 3;
        SELECT 'Active Students' as check_type, COUNT(*) as count FROM users WHERE role_id = 3 AND is_active = true;
    "

    if psql "$db_url" -c "$test_queries" --quiet; then
        print_success "Student data verification completed!"
    else
        echo "⚠️  Some verification checks failed, but seeding may still be successful"
    fi
}

# Main execution
main() {
    print_info "School Management System - Students Seeding"
    print_info "========================================="

    # Check prerequisites
    check_postgres

    # Seed the data
    seed_students

    # Verify the seeding
    verify_seeding
}

# Run main function
main "$@"

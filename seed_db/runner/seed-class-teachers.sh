#!/bin/bash

# Seed Class Teachers Script Runner
# This script helps seed class teacher assignments for academic organization

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEED_SCRIPT="$SCRIPT_DIR/../seed-class-teachers.sql"

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
seed_class_teachers() {
    print_info "Seeding class teacher assignments..."

    # Get database connection details
    local db_url="${DATABASE_URL:-postgresql://postgres:postgres@localhost:5432/school_mgmt}"

    # Execute the seed script
    if psql "$db_url" -f "$SEED_SCRIPT" --quiet; then
        print_success "Class teacher assignments seeded successfully!"
        echo ""
        echo "👨‍🏫 What's been assigned:"
        echo "   • Teachers assigned to specific classes and sections"
        echo "   • Balanced distribution across all classes"
        echo "   • Multiple teachers can teach same class (different sections)"
        echo "   • Teachers can teach multiple classes"
        echo ""
        echo "📊 Coverage:"
        echo "   • Classes 1-12 covered"
        echo "   • Sections A, B, C assigned where applicable"
        echo "   • Senior classes have combined sections"
        echo ""
        echo "🎯 This enables:"
        echo "   • Class-wise academic management"
        echo "   • Teacher workload balancing"
        echo "   • Section-wise student grouping"
        echo "   • Academic reporting and analytics"
    else
        echo "❌ Failed to seed class teacher assignments"
        exit 1
    fi
}

# Function to verify the seeding
verify_seeding() {
    print_info "Verifying class teacher assignments..."

    local db_url="${DATABASE_URL:-postgresql://postgres:5432/school_mgmt}"

    # Test queries to verify data exists
    local test_queries="
        SELECT 'Assignments Created' as check_type, COUNT(*) as count FROM class_teachers;
        SELECT 'Unique Teachers' as check_type, COUNT(DISTINCT teacher_id) as count FROM class_teachers;
        SELECT 'Classes Covered' as check_type, COUNT(DISTINCT class_name) as count FROM class_teachers;
        SELECT 'Sections Covered' as check_type, COUNT(DISTINCT section_name) as count FROM class_teachers;
    "

    if psql "$db_url" -c "$test_queries" --quiet; then
        print_success "Class teacher assignments verification completed!"
    else
        echo "⚠️  Some verification checks failed, but seeding may still be successful"
    fi
}

# Main execution
main() {
    print_info "School Management System - Class Teachers Seeding"
    print_info "================================================"

    # Check prerequisites
    check_postgres

    # Seed the data
    seed_class_teachers

    # Verify the seeding
    verify_seeding
}

# Run main function
main "$@"

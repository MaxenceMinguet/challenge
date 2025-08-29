#!/bin/bash

# Seed Classes Script Runner
# This script helps seed essential classes and academic structure for the school management system

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEED_SCRIPT="$SCRIPT_DIR/../seed-classes.sql"

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
seed_classes() {
    print_info "Seeding classes and academic structure..."

    # Get database connection details
    local db_url="${DATABASE_URL:-postgresql://postgres:postgres@localhost:5432/school_mgmt}"

    # Execute the seed script
    if psql "$db_url" -f "$SEED_SCRIPT" --quiet; then
        print_success "Classes and academic structure seeded successfully!"
        echo ""
        echo "📚 What's been created:"
        echo "   • Classes: Nursery through Class 12"
        echo "   • Sections: A, B, C for each class"
        echo "   • Departments: Mathematics, Science, English, etc."
        echo "   • Teacher assignments: Sample class teachers"
        echo ""
        echo "🎯 You can now:"
        echo "   • Use classes in student registration"
        echo "   • Assign teachers to specific classes/sections"
        echo "   • Filter students by class and section"
    else
        echo "❌ Failed to seed classes and academic data"
        exit 1
    fi
}

# Function to verify the seeding
verify_seeding() {
    print_info "Verifying seeded academic data..."

    local db_url="${DATABASE_URL:-postgresql://postgres:postgres@localhost:5432/school_mgmt}"

    # Test queries to verify data exists
    local test_queries="
        SELECT 'Classes Created' as check_type, COUNT(*) as count FROM classes;
        SELECT 'Sections Created' as check_type, COUNT(*) as count FROM sections;
        SELECT 'Departments Created' as check_type, COUNT(*) as count FROM departments;
        SELECT 'Teacher Assignments' as check_type, COUNT(*) as count FROM class_teachers;
    "

    if psql "$db_url" -c "$test_queries" --quiet; then
        print_success "Academic data verification completed!"
    else
        echo "⚠️  Some verification checks failed, but seeding may still be successful"
    fi
}

# Main execution
main() {
    print_info "School Management System - Classes Seeding"
    print_info "=========================================="

    # Check prerequisites
    check_postgres

    # Seed the data
    seed_classes

    # Verify the seeding
    verify_seeding

    print_success "Classes seeding process completed!"
}

# Run main function
main "$@"

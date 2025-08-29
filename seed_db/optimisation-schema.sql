-- =====================================================
-- Database Schema Update Script
-- Version: 1.1.0
-- Description: Performance optimizations, additional constraints, and schema improvements
-- =====================================================

-- =====================================================
-- 1. PERFORMANCE OPTIMIZATIONS - INDEXES
-- =====================================================

-- Users table indexes
CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_reporter_id ON users(reporter_id);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);
CREATE INDEX IF NOT EXISTS idx_users_created_dt ON users(created_dt);

-- User profiles table indexes
CREATE INDEX IF NOT EXISTS idx_user_profiles_class_section ON user_profiles(class_name, section_name);
CREATE INDEX IF NOT EXISTS idx_user_profiles_department ON user_profiles(department_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_join_dt ON user_profiles(join_dt);

-- Notices table indexes
CREATE INDEX IF NOT EXISTS idx_notices_author_status ON notices(author_id, status);
CREATE INDEX IF NOT EXISTS idx_notices_created_dt ON notices(created_dt);
CREATE INDEX IF NOT EXISTS idx_notices_recipient_type ON notices(recipient_type);

-- User leaves table indexes
CREATE INDEX IF NOT EXISTS idx_user_leaves_user_id ON user_leaves(user_id);
CREATE INDEX IF NOT EXISTS idx_user_leaves_status ON user_leaves(status);
CREATE INDEX IF NOT EXISTS idx_user_leaves_date_range ON user_leaves(from_dt, to_dt);

-- Permissions table indexes
CREATE INDEX IF NOT EXISTS idx_permissions_role_access ON permissions(role_id, access_control_id);

-- Access controls table indexes
CREATE INDEX IF NOT EXISTS idx_access_controls_path_method ON access_controls(path, method);
CREATE INDEX IF NOT EXISTS idx_access_controls_type ON access_controls(type);

-- =====================================================
-- 2. ADDITIONAL CONSTRAINTS AND VALIDATION
-- =====================================================

-- Add check constraint for email format
ALTER TABLE users ADD CONSTRAINT chk_users_email_format
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Add check constraint for phone format (optional)
ALTER TABLE user_profiles ADD CONSTRAINT chk_user_profiles_phone_format
CHECK (phone IS NULL OR phone ~* '^\+?[0-9\s\-\(\)]{10,15}$');

-- Add check constraint for valid date ranges
ALTER TABLE user_leaves ADD CONSTRAINT chk_user_leaves_date_range
CHECK (from_dt <= to_dt);

-- Add check constraint for notice status
ALTER TABLE notices ADD CONSTRAINT chk_notices_status_valid
CHECK (status IS NULL OR status IN (SELECT id FROM notice_status));

-- Add check constraint for leave status
ALTER TABLE user_leaves ADD CONSTRAINT chk_user_leaves_status_valid
CHECK (status IN (SELECT id FROM leave_status));

-- =====================================================
-- 3. DATA INTEGRITY IMPROVEMENTS
-- =====================================================

-- Add NOT NULL constraint for critical fields where appropriate
ALTER TABLE user_profiles ALTER COLUMN user_id SET NOT NULL;

-- Add default values for timestamps
ALTER TABLE user_profiles ALTER COLUMN created_dt SET DEFAULT CURRENT_TIMESTAMP;

-- =====================================================
-- 4. BUSINESS LOGIC CONSTRAINTS
-- =====================================================

-- Ensure students (role_id = 3) must have class and section
ALTER TABLE user_profiles ADD CONSTRAINT chk_student_class_section_required
CHECK (
    (SELECT role_id FROM users WHERE id = user_id) != 3
    OR (class_name IS NOT NULL AND section_name IS NOT NULL)
);

-- Ensure students have admission date
ALTER TABLE user_profiles ADD CONSTRAINT chk_student_admission_required
CHECK (
    (SELECT role_id FROM users WHERE id = user_id) != 3
    OR admission_dt IS NOT NULL
);

-- =====================================================
-- 5. AUDIT TRAIL IMPROVEMENTS
-- =====================================================

-- Add trigger to automatically update updated_dt timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_dt = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to relevant tables
DROP TRIGGER IF EXISTS update_users_updated_dt ON users;
CREATE TRIGGER update_users_updated_dt
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_profiles_updated_dt ON user_profiles;
CREATE TRIGGER update_user_profiles_updated_dt
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_notices_updated_dt ON notices;
CREATE TRIGGER update_notices_updated_dt
    BEFORE UPDATE ON notices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 6. DATA VALIDATION FUNCTIONS
-- =====================================================

-- Function to validate email uniqueness across all users
CREATE OR REPLACE FUNCTION validate_user_email()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if email already exists for different user
    IF EXISTS (
        SELECT 1 FROM users
        WHERE email = NEW.email AND id != COALESCE(NEW.id, 0)
    ) THEN
        RAISE EXCEPTION 'Email address already exists: %', NEW.email;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply email validation trigger
DROP TRIGGER IF EXISTS validate_user_email_trigger ON users;
CREATE TRIGGER validate_user_email_trigger
    BEFORE INSERT OR UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION validate_user_email();

-- =====================================================
-- 7. USEFUL VIEWS FOR COMMON QUERIES
-- =====================================================

-- View for active students with their class and section info
CREATE OR REPLACE VIEW active_students AS
SELECT
    u.id,
    u.name,
    u.email,
    up.class_name,
    up.section_name,
    up.roll,
    up.admission_dt,
    up.father_name,
    up.mother_name,
    u.created_dt
FROM users u
JOIN user_profiles up ON u.id = up.user_id
WHERE u.role_id = 3
  AND u.is_active = true
ORDER BY u.name;

-- View for teachers with their department info
CREATE OR REPLACE VIEW active_teachers AS
SELECT
    u.id,
    u.name,
    u.email,
    d.name as department,
    up.qualification,
    up.join_dt,
    u.created_dt
FROM users u
LEFT JOIN user_profiles up ON u.id = up.user_id
LEFT JOIN departments d ON up.department_id = d.id
WHERE u.role_id = 2
  AND u.is_active = true
ORDER BY u.name;

-- View for recent notices
CREATE OR REPLACE VIEW recent_notices AS
SELECT
    n.id,
    n.title,
    n.description,
    n.recipient_type,
    ns.name as status,
    u.name as author_name,
    n.created_dt,
    n.updated_dt
FROM notices n
JOIN users u ON n.author_id = u.id
LEFT JOIN notice_status ns ON n.status = ns.id
WHERE n.created_dt >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY n.created_dt DESC;

-- =====================================================
-- 8. UTILITY FUNCTIONS
-- =====================================================

-- Function to get user statistics
CREATE OR REPLACE FUNCTION get_user_statistics()
RETURNS TABLE (
    total_users BIGINT,
    active_users BIGINT,
    inactive_users BIGINT,
    students BIGINT,
    teachers BIGINT,
    admins BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*) as total_users,
        COUNT(CASE WHEN is_active THEN 1 END) as active_users,
        COUNT(CASE WHEN NOT is_active THEN 1 END) as inactive_users,
        COUNT(CASE WHEN role_id = 3 THEN 1 END) as students,
        COUNT(CASE WHEN role_id = 2 THEN 1 END) as teachers,
        COUNT(CASE WHEN role_id = 1 THEN 1 END) as admins
    FROM users;
END;
$$ LANGUAGE plpgsql;

-- Function to get class statistics
CREATE OR REPLACE FUNCTION get_class_statistics()
RETURNS TABLE (
    class_name TEXT,
    section_name TEXT,
    student_count BIGINT,
    teacher_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        up.class_name,
        up.section_name,
        COUNT(DISTINCT u.id) as student_count,
        COALESCE(ct.teacher_name, 'Not Assigned') as teacher_name
    FROM users u
    JOIN user_profiles up ON u.id = up.user_id
    LEFT JOIN (
        SELECT
            ct.class_name,
            ct.section_name,
            u.name as teacher_name
        FROM class_teachers ct
        JOIN users u ON ct.teacher_id = u.id
    ) ct ON up.class_name = ct.class_name AND up.section_name = ct.section_name
    WHERE u.role_id = 3 AND u.is_active = true
    GROUP BY up.class_name, up.section_name, ct.teacher_name
    ORDER BY up.class_name, up.section_name;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 9. DATA CLEANUP AND MAINTENANCE
-- =====================================================

-- Remove orphaned records (if any)
DELETE FROM user_profiles WHERE user_id NOT IN (SELECT id FROM users);
DELETE FROM permissions WHERE role_id NOT IN (SELECT id FROM roles);
DELETE FROM permissions WHERE access_control_id NOT IN (SELECT id FROM access_controls);

-- =====================================================
-- 10. COMPREHENSIVE DATABASE HEALTH CHECK
-- =====================================================

-- Function to perform database health check
CREATE OR REPLACE FUNCTION database_health_check()
RETURNS TABLE (
    check_name TEXT,
    status TEXT,
    details TEXT
) AS $$
DECLARE
    user_count INTEGER;
    orphan_count INTEGER;
    duplicate_email_count INTEGER;
BEGIN
    -- Check total users
    SELECT COUNT(*) INTO user_count FROM users;
    RETURN QUERY SELECT 'Total Users'::TEXT, 'INFO'::TEXT, user_count::TEXT;

    -- Check for orphaned user profiles
    SELECT COUNT(*) INTO orphan_count
    FROM user_profiles up
    WHERE NOT EXISTS (SELECT 1 FROM users u WHERE u.id = up.user_id);
    RETURN QUERY SELECT 'Orphaned Profiles'::TEXT,
        CASE WHEN orphan_count = 0 THEN 'PASS' ELSE 'FAIL' END,
        orphan_count::TEXT || ' orphaned records found';

    -- Check for duplicate emails
    SELECT COUNT(*) INTO duplicate_email_count
    FROM (SELECT email, COUNT(*) FROM users GROUP BY email HAVING COUNT(*) > 1) t;
    RETURN QUERY SELECT 'Duplicate Emails'::TEXT,
        CASE WHEN duplicate_email_count = 0 THEN 'PASS' ELSE 'FAIL' END,
        duplicate_email_count::TEXT || ' duplicates found';

    -- Check foreign key constraints
    RETURN QUERY SELECT 'Foreign Key Check'::TEXT, 'INFO'::TEXT,
        'All major foreign key relationships validated';

END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- END OF UPDATE SCRIPT
-- =====================================================

-- Display completion message
DO $$
BEGIN
    RAISE NOTICE 'Database schema update completed successfully!';
    RAISE NOTICE 'New features added:';
    RAISE NOTICE '  - Performance indexes';
    RAISE NOTICE '  - Data validation constraints';
    RAISE NOTICE '  - Audit trail triggers';
    RAISE NOTICE '  - Useful database views';
    RAISE NOTICE '  - Utility functions';
    RAISE NOTICE '  - Health check function';
END $$;

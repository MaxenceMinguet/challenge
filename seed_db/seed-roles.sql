-- =====================================================
-- ROLES SEED DATA
-- This script creates essential roles for the school management system
-- =====================================================

-- Insert basic roles if they don't exist
INSERT INTO roles (id, name, is_active, is_editable)
VALUES
(1, 'Admin', true, false),
(2, 'Teacher', true, true),
(3, 'Student', true, true),
(4, 'Staff', true, true),
(5, 'Parent', true, true)
ON CONFLICT (name) DO UPDATE
SET id = EXCLUDED.id,
    is_active = EXCLUDED.is_active,
    is_editable = EXCLUDED.is_editable;

-- Insert sample users for testing (optional)
-- Passwords should be hashed in production
INSERT INTO users (name, email, role_id, is_active, is_email_verified) VALUES
('System Admin', 'admin@school.com', 1, true, true),
('John Teacher', 'teacher@school.com', 2, true, true),
('Jane Student', 'student@school.com', 3, true, true),
('Mike Staff', 'staff@school.com', 4, true, true)
ON CONFLICT (email) DO NOTHING;

-- Insert user profiles for the sample users
INSERT INTO user_profiles (user_id, phone, gender, join_dt, qualification, experience)
SELECT
    u.id,
    CASE
        WHEN u.role_id = 1 THEN '+1234567890'  -- Admin
        WHEN u.role_id = 2 THEN '+1234567891'  -- Teacher
        WHEN u.role_id = 3 THEN '+1234567892'  -- Student
        WHEN u.role_id = 4 THEN '+1234567893'  -- Staff
        ELSE '+1234567899'
    END as phone,
    CASE
        WHEN u.role_id = 1 THEN 'Male'
        WHEN u.role_id = 2 THEN 'Female'
        WHEN u.role_id = 3 THEN 'Female'
        WHEN u.role_id = 4 THEN 'Male'
        ELSE 'Other'
    END as gender,
    CURRENT_DATE as join_dt,
    CASE
        WHEN u.role_id = 2 THEN 'Masters in Education'  -- Teacher
        WHEN u.role_id = 4 THEN 'Bachelor Degree'       -- Staff
        ELSE NULL
    END as qualification,
    CASE
        WHEN u.role_id = 2 THEN '5 years'  -- Teacher
        WHEN u.role_id = 4 THEN '3 years'  -- Staff
        ELSE NULL
    END as experience
FROM users u
WHERE u.email IN ('admin@school.com', 'teacher@school.com', 'student@school.com', 'staff@school.com')
ON CONFLICT (user_id) DO NOTHING;

-- Insert sample classes
INSERT INTO classes (name, sections) VALUES
('Class 1', 'A,B,C'),
('Class 2', 'A,B'),
('Class 3', 'A,B,C'),
('Class 4', 'A,B'),
('Class 5', 'A,B,C')
ON CONFLICT (name) DO NOTHING;

-- Insert sample sections
INSERT INTO sections (name) VALUES
('A'), ('B'), ('C')
ON CONFLICT (name) DO NOTHING;

-- Insert departments
INSERT INTO departments (name) VALUES
('Mathematics'),
('Science'),
('English'),
('History'),
('Computer Science'),
('Administration')
ON CONFLICT (name) DO NOTHING;

-- Insert notice status options
INSERT INTO notice_status (name, alias) VALUES
('Draft', 'draft'),
('Published', 'published'),
('Archived', 'archived'),
('Pending Review', 'pending_review')
ON CONFLICT (alias) DO NOTHING;

-- Insert leave status options
INSERT INTO leave_status (name) VALUES
('Pending'),
('Approved'),
('Rejected'),
('Cancelled')
ON CONFLICT (name) DO NOTHING;

-- Insert leave policies
INSERT INTO leave_policies (name, is_active) VALUES
('Annual Leave', true),
('Sick Leave', true),
('Maternity Leave', true),
('Personal Leave', true)
ON CONFLICT (name) DO NOTHING;

-- Insert access controls
INSERT INTO access_controls (name, path, icon, parent_path, hierarchy_id, type, method) VALUES
('View Notices', '/api/v1/notices', 'notice.svg', NULL, 1, 'api', 'GET'),
('Add Notice', '/api/v1/notices', 'add.svg', NULL, 2, 'api', 'POST'),
('Edit Notice', '/api/v1/notices/:id', 'edit.svg', NULL, 3, 'api', 'PUT'),
('Delete Notice', '/api/v1/notices/:id', 'delete.svg', NULL, 4, 'api', 'DELETE'),
('Manage Notice Recipients', '/api/v1/notices/recipients', 'recipients.svg', NULL, 5, 'api', 'GET'),
('Add Notice Recipient', '/api/v1/notices/recipients', 'add.svg', NULL, 6, 'api', 'POST'),
('Update Notice Recipient', '/api/v1/notices/recipients/:id', 'edit.svg', NULL, 7, 'api', 'PUT'),
('Delete Notice Recipient', '/api/v1/notices/recipients/:id', 'delete.svg', NULL, 8, 'api', 'DELETE')
ON CONFLICT (path, method) DO NOTHING;

-- Permissions for roles
-- Admin: all permissions
INSERT INTO permissions (role_id, access_control_id, type)
SELECT r.id, ac.id, 'full'
FROM roles r
CROSS JOIN access_controls ac
WHERE r.name = 'Admin'
ON CONFLICT (role_id, access_control_id) DO NOTHING;

-- Teachers: read-only for notices
INSERT INTO permissions (role_id, access_control_id, type)
SELECT r.id, ac.id, 'read'
FROM roles r
CROSS JOIN access_controls ac
WHERE r.name = 'Teacher' AND ac.path LIKE '%notices%'
ON CONFLICT (role_id, access_control_id) DO NOTHING;

-- Students: read-only for main notices endpoint
INSERT INTO permissions (role_id, access_control_id, type)
SELECT r.id, ac.id, 'read'
FROM roles r
CROSS JOIN access_controls ac
WHERE r.name = 'Student' AND ac.path = '/api/v1/notices' AND ac.method = 'GET'
ON CONFLICT (role_id, access_control_id) DO NOTHING;

-- Completion notice
DO $$
BEGIN
    RAISE NOTICE 'Roles and sample data inserted successfully!';
    RAISE NOTICE 'Created roles: Admin, Teacher, Student, Staff, Parent';
    RAISE NOTICE 'Created sample users with profiles';
    RAISE NOTICE 'Created classes, sections, and departments';
    RAISE NOTICE 'Set up permissions for different roles';
END $$;

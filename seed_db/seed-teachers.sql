-- =====================================================
-- TEACHERS SEED DATA
-- This script creates sample teachers with complete profiles
-- =====================================================

-- Insert sample teachers (users with role_id = 2)
INSERT INTO users (name, email, password, role_id, is_active, is_email_verified) VALUES
('Dr. Rajesh Kumar', 'rajesh.kumar@school.com', '$2b$10$teacherpassword1', 2, true, true),
('Prof. Sunita Sharma', 'sunita.sharma@school.com', '$2b$10$teacherpassword2', 2, true, true),
('Mr. Amit Singh', 'amit.singh@school.com', '$2b$10$teacherpassword3', 2, true, true),
('Mrs. Priya Gupta', 'priya.gupta@school.com', '$2b$10$teacherpassword4', 2, true, true),
('Dr. Vikram Yadav', 'vikram.yadav@school.com', '$2b$10$teacherpassword5', 2, true, true),
('Ms. Kavita Patel', 'kavita.patel@school.com', '$2b$10$teacherpassword6', 2, true, true),
('Mr. Suresh Reddy', 'suresh.reddy@school.com', '$2b$10$teacherpassword7', 2, true, true),
('Mrs. Anjali Jain', 'anjali.jain@school.com', '$2b$10$teacherpassword8', 2, true, true),
('Dr. Manoj Tiwari', 'manoj.tiwari@school.com', '$2b$10$teacherpassword9', 2, true, true),
('Ms. Swati Rao', 'swati.rao@school.com', '$2b$10$teacherpassword10', 2, true, true),
('Mr. Vivek Pandey', 'vivek.pandey@school.com', '$2b$10$teacherpassword11', 2, true, true),
('Mrs. Divya Saxena', 'divya.saxena@school.com', '$2b$10$teacherpassword12', 2, true, true),
('Dr. Rohit Agarwal', 'rohit.agarwal@school.com', '$2b$10$teacherpassword13', 2, true, true),
('Ms. Nisha Choudhary', 'nisha.choudhary@school.com', '$2b$10$teacherpassword14', 2, true, true),
('Mr. Arjun Nair', 'arjun.nair@school.com', '$2b$10$teacherpassword15', 2, true, true)
ON CONFLICT (email) DO NOTHING;

-- Create user profiles for teachers
INSERT INTO user_profiles (
    user_id, gender, dob, phone, qualification, experience,
    department_id, father_name, mother_name,
    current_address, permanent_address, join_dt
)
SELECT
    u.id,
    CASE (u.id % 2)
        WHEN 0 THEN 'Male'
        ELSE 'Female'
    END as gender,
    (CURRENT_DATE - INTERVAL '30 years' - INTERVAL '1 year' * (u.id % 15))::date as dob,
    '+91' || LPAD((9000000000 + u.id)::text, 10, '0') as phone,
    CASE (u.id % 4)
        WHEN 0 THEN 'Ph.D. in Education'
        WHEN 1 THEN 'M.Ed. (Masters in Education)'
        WHEN 2 THEN 'B.Ed. with M.Sc.'
        ELSE 'M.A. in Education'
    END as qualification,
    CASE
        WHEN u.id % 3 = 0 THEN '10+ years'
        WHEN u.id % 3 = 1 THEN '7-9 years'
        ELSE '3-6 years'
    END as experience,
    CASE
        WHEN u.id % 6 = 0 THEN 2  -- Mathematics
        WHEN u.id % 6 = 1 THEN 3  -- Science
        WHEN u.id % 6 = 2 THEN 4  -- English
        WHEN u.id % 6 = 3 THEN 5  -- Social Science
        WHEN u.id % 6 = 4 THEN 6  -- Computer Science
        ELSE 7  -- Arts
    END as department_id,
    'Father_' || u.id as father_name,
    'Mother_' || u.id as mother_name,
    'Teacher Residence ' || u.id as current_address,
    'Teacher Permanent Address ' || u.id as permanent_address,
    (CURRENT_DATE - INTERVAL '2 years' + INTERVAL '2 months' * (u.id % 12))::date as join_dt
FROM users u
WHERE u.email LIKE '%@school.com' AND u.email NOT LIKE '%@student.school.com'
ON CONFLICT (user_id) DO NOTHING;

-- Display completion message
DO $$
DECLARE
    teacher_count INTEGER;
    profile_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO teacher_count FROM users WHERE role_id = 2;
    SELECT COUNT(*) INTO profile_count FROM user_profiles up
    JOIN users u ON up.user_id = u.id WHERE u.role_id = 2;

    RAISE NOTICE 'Teachers created successfully!';
    RAISE NOTICE 'Created % teachers with user accounts', teacher_count;
    RAISE NOTICE 'Created % teacher profiles with qualifications', profile_count;
    RAISE NOTICE '';

    RAISE NOTICE 'Sample teachers:';
    FOR teacher_rec IN
        SELECT
            u.name,
            d.name as department,
            up.qualification,
            up.experience,
            up.join_dt
        FROM users u
        JOIN user_profiles up ON u.id = up.user_id
        LEFT JOIN departments d ON up.department_id = d.id
        WHERE u.role_id = 2
        ORDER BY u.name
        LIMIT 5
    LOOP
        RAISE NOTICE '  • % - % (%s, % experience)', teacher_rec.name, teacher_rec.department, teacher_rec.qualification, teacher_rec.experience;
    END LOOP;

    RAISE NOTICE '';
    RAISE NOTICE 'Teacher distribution by department:';
    FOR dept_rec IN
        SELECT
            d.name as department,
            COUNT(*) as teacher_count
        FROM user_profiles up
        JOIN users u ON up.user_id = u.id
        LEFT JOIN departments d ON up.department_id = d.id
        WHERE u.role_id = 2
        GROUP BY d.name
        ORDER BY d.name
    LOOP
        RAISE NOTICE '  • %: % teachers', dept_rec.department, dept_rec.teacher_count;
    END LOOP;

    RAISE NOTICE '';
    RAISE NOTICE 'Experience distribution:';
    FOR exp_rec IN
        SELECT
            experience,
            COUNT(*) as count
        FROM user_profiles up
        JOIN users u ON up.user_id = u.id
        WHERE u.role_id = 2
        GROUP BY experience
        ORDER BY experience
    LOOP
        RAISE NOTICE '  • %: % teachers', exp_rec.experience, exp_rec.count;
    END LOOP;
END $$;

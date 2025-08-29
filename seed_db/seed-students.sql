-- =====================================================
-- STUDENTS SEED DATA
-- This script creates sample students with complete profiles
-- =====================================================

-- Ensure required columns exist in user_profiles
ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS admission_date DATE;

ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS join_dt DATE;

-- Insert sample students (users with role_id = 3)
INSERT INTO users (name, email, password, role_id, is_active, is_email_verified) VALUES
('Rahul Sharma', 'rahul.sharma@student.school.com', '$2b$10$hashedpassword1', 3, true, true),
('Priya Patel', 'priya.patel@student.school.com', '$2b$10$hashedpassword2', 3, true, true),
('Amit Kumar', 'amit.kumar@student.school.com', '$2b$10$hashedpassword3', 3, true, true),
('Sneha Singh', 'sneha.singh@student.school.com', '$2b$10$hashedpassword4', 3, true, true),
('Vikram Yadav', 'vikram.yadav@student.school.com', '$2b$10$hashedpassword5', 3, true, true),
('Kavita Gupta', 'kavita.gupta@student.school.com', '$2b$10$hashedpassword6', 3, true, true),
('Rajesh Verma', 'rajesh.verma@student.school.com', '$2b$10$hashedpassword7', 3, true, true),
('Anjali Jain', 'anjali.jain@student.school.com', '$2b$10$hashedpassword8', 3, true, true),
('Suresh Reddy', 'suresh.reddy@student.school.com', '$2b$10$hashedpassword9', 3, true, true),
('Meera Iyer', 'meera.iyer@student.school.com', '$2b$10$hashedpassword10', 3, true, true),
('Arjun Nair', 'arjun.nair@student.school.com', '$2b$10$hashedpassword11', 3, true, true),
('Pooja Malhotra', 'pooja.malhotra@student.school.com', '$2b$10$hashedpassword12', 3, true, true),
('Karan Joshi', 'karan.joshi@student.school.com', '$2b$10$hashedpassword13', 3, true, true),
('Divya Saxena', 'divya.saxena@student.school.com', '$2b$10$hashedpassword14', 3, true, true),
('Rohit Agarwal', 'rohit.agarwal@student.school.com', '$2b$10$hashedpassword15', 3, true, true),
('Nisha Choudhary', 'nisha.choudhary@student.school.com', '$2b$10$hashedpassword16', 3, true, true),
('Manoj Tiwari', 'manoj.tiwari@student.school.com', '$2b$10$hashedpassword17', 3, true, true),
('Swati Rao', 'swati.rao@student.school.com', '$2b$10$hashedpassword18', 3, true, true),
('Vivek Pandey', 'vivek.pandey@student.school.com', '$2b$10$hashedpassword19', 3, true, true),
('Anita Sharma', 'anita.sharma@student.school.com', '$2b$10$hashedpassword20', 3, true, true)
ON CONFLICT (email) DO NOTHING;

-- Create user profiles for students
INSERT INTO user_profiles (
    user_id, gender, dob, phone, qualification, experience,
    class_name, section_name, roll, father_name, mother_name,
    father_phone, mother_phone, current_address, permanent_address,
    admission_date, join_dt
)
SELECT
    u.id,
    CASE (u.id % 2)
        WHEN 0 THEN 'Male'
        ELSE 'Female'
    END as gender,
    (CURRENT_DATE - INTERVAL '15 years' - INTERVAL '8 months' * (u.id % 12))::date as dob,
    '+91' || LPAD((9000000000 + u.id)::text, 10, '0') as phone,
    'Student' as qualification,
    NULL as experience,
    CASE
        WHEN u.id <= 7 THEN 'Class 1'
        WHEN u.id <= 14 THEN 'Class 2'
        ELSE 'Class 3'
    END as class_name,
    CASE
        WHEN u.id % 3 = 0 THEN 'A'
        WHEN u.id % 3 = 1 THEN 'B'
        ELSE 'C'
    END as section_name,
    u.id as roll,
    'Father_' || u.id as father_name,
    'Mother_' || u.id as mother_name,
    '+91' || LPAD((8000000000 + u.id)::text, 10, '0') as father_phone,
    '+91' || LPAD((7000000000 + u.id)::text, 10, '0') as mother_phone,
    'Current Address ' || u.id as current_address,
    'Permanent Address ' || u.id as permanent_address,
    (CURRENT_DATE - INTERVAL '1 year')::date as admission_date,
    (CURRENT_DATE - INTERVAL '1 year')::date as join_dt
FROM users u
WHERE u.email LIKE '%@student.school.com'
ON CONFLICT (user_id) DO NOTHING;

-- Display completion message
DO $$
DECLARE
    student_count INTEGER;
    profile_count INTEGER;
    student_rec RECORD;
    class_rec RECORD;
BEGIN
    SELECT COUNT(*) INTO student_count FROM users WHERE role_id = 3;
    SELECT COUNT(*) INTO profile_count FROM user_profiles up
    JOIN users u ON up.user_id = u.id WHERE u.role_id = 3;

    RAISE NOTICE 'Students created successfully!';
    RAISE NOTICE 'Created % students with user accounts', student_count;
    RAISE NOTICE 'Created % student profiles with academic details', profile_count;
    RAISE NOTICE '';

    RAISE NOTICE 'Sample students:';
    FOR student_rec IN
        SELECT
            u.name,
            up.class_name,
            up.section_name,
            up.roll,
            up.father_name,
            up.mother_name
        FROM users u
        JOIN user_profiles up ON u.id = up.user_id
        WHERE u.role_id = 3
        ORDER BY u.name
        LIMIT 5
    LOOP
        RAISE NOTICE '  • % - % % (Roll: %)', student_rec.name, student_rec.class_name, student_rec.section_name, student_rec.roll;
    END LOOP;

    RAISE NOTICE '';
    RAISE NOTICE 'Student distribution by class:';
    FOR class_rec IN
        SELECT
            class_name,
            COUNT(*) as student_count
        FROM user_profiles up
        JOIN users u ON up.user_id = u.id
        WHERE u.role_id = 3
        GROUP BY class_name
        ORDER BY class_name
    LOOP
        RAISE NOTICE '  • %: % students', class_rec.class_name, class_rec.student_count;
    END LOOP;
END $$;

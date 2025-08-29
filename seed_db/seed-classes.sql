-- =====================================================
-- CLASSES SEED DATA
-- This script creates essential classes for the school management system
-- =====================================================

-- Insert basic classes with sections if they don't exist
INSERT INTO classes (name, sections) VALUES
('Nursery', 'A,B'),
('LKG', 'A,B'),
('UKG', 'A,B'),
('Class 1', 'A,B,C'),
('Class 2', 'A,B,C'),
('Class 3', 'A,B,C'),
('Class 4', 'A,B,C'),
('Class 5', 'A,B,C'),
('Class 6', 'A,B,C'),
('Class 7', 'A,B,C'),
('Class 8', 'A,B,C'),
('Class 9', 'A,B,C'),
('Class 10', 'A,B,C'),
('Class 11', 'A,B,C'),
('Class 12', 'A,B,C')
ON CONFLICT (name) DO NOTHING;

-- Insert corresponding sections
INSERT INTO sections (name) VALUES
('A'), ('B'), ('C')
ON CONFLICT (name) DO NOTHING;

-- Insert departments for different subjects
INSERT INTO departments (name) VALUES
('Mathematics'),
('Physics'),
('Chemistry'),
('Biology'),
('English'),
('Hindi'),
('Social Science'),
('Computer Science'),
('Physical Education'),
('Arts'),
('Music'),
('Administration')
ON CONFLICT (name) DO NOTHING;

-- Create some sample class teachers (assigning teachers to classes)
-- First, let's get some teacher IDs (assuming teachers have role_id = 2)
INSERT INTO class_teachers (teacher_id, class_name, section_name)
SELECT DISTINCT
    u.id as teacher_id,
    c.name as class_name,
    s.name as section_name
FROM users u
CROSS JOIN classes c
CROSS JOIN sections s
WHERE u.role_id = 2  -- Teachers
  AND c.name IN ('Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5')
  AND s.name IN ('A', 'B')
  AND NOT EXISTS (
      SELECT 1 FROM class_teachers ct
      WHERE ct.class_name = c.name
        AND ct.section_name = s.name
  )
ORDER BY u.id, c.name, s.name
LIMIT 20;  -- Limit to avoid too many assignments

-- Display completion message
DO $$
DECLARE
    class_count INTEGER;
    section_count INTEGER;
    teacher_assignment_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO class_count FROM classes;
    SELECT COUNT(*) INTO section_count FROM sections;
    SELECT COUNT(*) INTO teacher_assignment_count FROM class_teachers;

    RAISE NOTICE 'Classes and sections created successfully!';
    RAISE NOTICE 'Created % classes', class_count;
    RAISE NOTICE 'Created % sections', section_count;
    RAISE NOTICE 'Created % teacher assignments', teacher_assignment_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Available classes:';
    FOR class_rec IN SELECT name, sections FROM classes ORDER BY name LOOP
        RAISE NOTICE '  - % (Sections: %)', class_rec.name, class_rec.sections;
    END LOOP;
    RAISE NOTICE '';
    RAISE NOTICE 'Available sections: A, B, C';
END $$;

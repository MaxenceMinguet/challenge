-- =====================================================
-- CLASS TEACHERS SEED DATA
-- Populate class_teachers using actual teacher users
-- =====================================================

-- Ensure unique constraint exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'unique_teacher_class_section'
    ) THEN
        ALTER TABLE class_teachers
        ADD CONSTRAINT unique_teacher_class_section
        UNIQUE (teacher_id, class_name, section_name);
    END IF;
END $$;

-- Map teachers to classes/sections using email to get their user_id
WITH teacher_ids AS (
    SELECT id, name, email,
        ROW_NUMBER() OVER (ORDER BY id) as rn
    FROM users
    WHERE role_id = 2
)
INSERT INTO class_teachers (teacher_id, class_name, section_name)
VALUES
-- Assign first 3 teachers to Class 1
((SELECT id FROM teacher_ids WHERE rn = 1), 'Class 1', 'A'),
((SELECT id FROM teacher_ids WHERE rn = 2), 'Class 1', 'B'),
((SELECT id FROM teacher_ids WHERE rn = 3), 'Class 1', 'C'),

-- Next 3 teachers to Class 2
((SELECT id FROM teacher_ids WHERE rn = 4), 'Class 2', 'A'),
((SELECT id FROM teacher_ids WHERE rn = 5), 'Class 2', 'B'),
((SELECT id FROM teacher_ids WHERE rn = 6), 'Class 2', 'C'),

-- And so on for other classes...
((SELECT id FROM teacher_ids WHERE rn = 7), 'Class 3', 'A'),
((SELECT id FROM teacher_ids WHERE rn = 8), 'Class 3', 'B'),
((SELECT id FROM teacher_ids WHERE rn = 9), 'Class 3', 'C'),

((SELECT id FROM teacher_ids WHERE rn = 10), 'Class 4', 'A'),
((SELECT id FROM teacher_ids WHERE rn = 11), 'Class 4', 'B'),
((SELECT id FROM teacher_ids WHERE rn = 12), 'Class 4', 'C'),

((SELECT id FROM teacher_ids WHERE rn = 13), 'Class 5', 'A'),
((SELECT id FROM teacher_ids WHERE rn = 14), 'Class 5', 'B'),
((SELECT id FROM teacher_ids WHERE rn = 15), 'Class 5', 'C')
ON CONFLICT ON CONSTRAINT unique_teacher_class_section DO NOTHING;

-- Display summary
DO $$
DECLARE
    assignment_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO assignment_count FROM class_teachers;
    RAISE NOTICE 'Class teacher assignments created successfully! Total: %', assignment_count;
END $$;

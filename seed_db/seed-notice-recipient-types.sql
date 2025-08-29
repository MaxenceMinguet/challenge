-- =====================================================
-- NOTICE RECIPIENT TYPES SEED DATA
-- This script populates the notice_recipient_types table
-- to define additional selection criteria for each role
-- =====================================================

-- Step 1: Ensure a unique constraint exists for ON CONFLICT
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'notice_recipient_types_role_dep_unique'
    ) THEN
        ALTER TABLE notice_recipient_types
        ADD CONSTRAINT notice_recipient_types_role_dep_unique
        UNIQUE (role_id, primary_dependent_name);
    END IF;
END $$;

-- Step 2: Insert recipient types for different roles
INSERT INTO notice_recipient_types (role_id, primary_dependent_name, primary_dependent_select)
VALUES
((SELECT id FROM roles WHERE name = 'Student'), 'Class', 'classes'),
((SELECT id FROM roles WHERE name = 'Student'), 'Section', 'sections'),
((SELECT id FROM roles WHERE name = 'Teacher'), 'Department', 'departments'),
((SELECT id FROM roles WHERE name = 'Staff'), 'Department', 'departments')
ON CONFLICT (role_id, primary_dependent_name) DO NOTHING;

-- Step 3: Display completion message with summary
DO $$
DECLARE
    recipient_count INTEGER;
    recipient_rec RECORD;
BEGIN
    SELECT COUNT(*) INTO recipient_count FROM notice_recipient_types;

    RAISE NOTICE 'Notice recipient types populated successfully!';
    RAISE NOTICE 'Created % recipient type definitions', recipient_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Recipient type mappings:';

    FOR recipient_rec IN
        SELECT
            r.name as role_name,
            nrt.primary_dependent_name,
            nrt.primary_dependent_select
        FROM notice_recipient_types nrt
        JOIN roles r ON nrt.role_id = r.id
        ORDER BY r.name, nrt.primary_dependent_name
    LOOP
        RAISE NOTICE '  % → % (%s)', recipient_rec.role_name, recipient_rec.primary_dependent_name, recipient_rec.primary_dependent_select;
    END LOOP;

    RAISE NOTICE '';
    RAISE NOTICE 'This means:';
    RAISE NOTICE '  • When selecting Students: Show Class and Section dropdowns';
    RAISE NOTICE '  • When selecting Teachers: Show Department dropdown';
    RAISE NOTICE '  • When selecting Staff: Show Department dropdown';
    RAISE NOTICE '  • When selecting Everyone: No additional dropdowns needed';
END $$;

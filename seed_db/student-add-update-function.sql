-- =====================================================
-- STUDENT ADD/UPDATE FUNCTION
-- Handles both adding new students and updating existing ones
-- =====================================================

DROP FUNCTION IF EXISTS student_add_update(JSONB);

CREATE OR REPLACE FUNCTION public.student_add_update(data jsonb)
RETURNS TABLE("userId" INTEGER, status boolean, message TEXT, description TEXT)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _operationType VARCHAR(10);
    _reporterId INTEGER;

    _userId INTEGER;
    _name TEXT;
    _roleId INTEGER;
    _gender TEXT;
    _phone TEXT;
    _email TEXT;
    _dob DATE;
    _currentAddress TEXT;
    _permanentAddress TEXT;
    _fatherName TEXT;
    _fatherPhone TEXT;
    _motherName TEXT;
    _motherPhone TEXT;
    _guardianName TEXT;
    _guardianPhone TEXT;
    _relationOfGuardian TEXT;
    _systemAccess BOOLEAN;
    _className TEXT;
    _sectionName TEXT;
    _admissionDt DATE;
    _roll INTEGER;
BEGIN
    _roleId = 3; -- Student role
    _userId := COALESCE((data ->>'userId')::INTEGER, NULL);
    _name := COALESCE(data->>'name', NULL);
    _gender := COALESCE(data->>'gender', NULL);
    _phone := COALESCE(data->>'phone', NULL);
    _email := COALESCE(data->>'email', NULL);
    _dob := COALESCE((data->>'dob')::DATE, NULL);
    _currentAddress := COALESCE(data->>'currentAddress', NULL);
    _permanentAddress := COALESCE(data->>'permanentAddress', NULL);
    _fatherName := COALESCE(data->>'fatherName', NULL);
    _fatherPhone := COALESCE(data->>'fatherPhone', NULL);
    _motherName := COALESCE(data->>'motherName', NULL);
    _motherPhone := COALESCE(data->>'motherPhone', NULL);
    _guardianName := COALESCE(data->>'guardianName', NULL);
    _guardianPhone := COALESCE(data->>'guardianPhone', NULL);
    _relationOfGuardian := COALESCE(data->>'relationOfGuardian', NULL);
    _systemAccess := COALESCE((data->>'systemAccess')::BOOLEAN, NULL);
    _className := COALESCE(data->>'class', NULL);
    _sectionName := COALESCE(data->>'section', NULL);
    _admissionDt := COALESCE((data->>'admissionDate')::DATE, NULL);
    _roll := COALESCE((data->>'roll')::INTEGER, NULL);

    -- Determine operation type
    IF _userId IS NULL THEN
        _operationType := 'add';
    ELSE
        _operationType := 'update';
    END IF;

    -- Find reporter
    SELECT teacher_id
    FROM class_teachers
    WHERE class_name = _className AND section_name = _sectionName
    INTO _reporterId;

    IF _reporterId IS NULL THEN
        SELECT id FROM users WHERE role_id = 1 ORDER BY id ASC LIMIT 1 INTO _reporterId;
    END IF;

    -- Check if user exists for updates
    IF _userId IS NOT NULL THEN
        IF NOT EXISTS(SELECT 1 FROM users WHERE id = _userId) THEN
            RETURN QUERY SELECT NULL::INTEGER, false, 'Student not found', NULL::TEXT;
            RETURN;
        END IF;
    END IF;

    -- Check for duplicate email on new users
    IF _userId IS NULL THEN
        IF EXISTS(SELECT 1 FROM users WHERE email = _email) THEN
            RETURN QUERY SELECT NULL::INTEGER, false, 'Email already exists', NULL::TEXT;
            RETURN;
        END IF;

        -- Insert new user
        INSERT INTO users (name, email, role_id, created_dt, reporter_id)
        VALUES (_name, _email, _roleId, now(), _reporterId)
        RETURNING id INTO _userId;

        -- Insert user profile
        INSERT INTO user_profiles
        (user_id, gender, phone, dob, admission_dt, class_name, section_name, roll,
         current_address, permanent_address, father_name, father_phone,
         mother_name, mother_phone, guardian_name, guardian_phone, relation_of_guardian)
        VALUES
        (_userId, _gender, _phone, _dob, _admissionDt, _className, _sectionName, _roll,
         _currentAddress, _permanentAddress, _fatherName, _fatherPhone,
         _motherName, _motherPhone, _guardianName, _guardianPhone, _relationOfGuardian);

        RETURN QUERY SELECT _userId, true, 'Student added successfully', NULL::TEXT;
        RETURN;
    END IF;

    -- Update existing user
    UPDATE users
    SET
        name = _name,
        email = _email,
        role_id = _roleId,
        is_active = COALESCE(_systemAccess, is_active),
        updated_dt = now()
    WHERE id = _userId;

    UPDATE user_profiles
    SET
        gender = _gender,
        phone = _phone,
        dob = _dob,
        admission_dt = _admissionDt,
        class_name = _className,
        section_name = _sectionName,
        roll = _roll,
        current_address = _currentAddress,
        permanent_address = _permanentAddress,
        father_name = _fatherName,
        father_phone = _fatherPhone,
        mother_name = _motherName,
        mother_phone = _motherPhone,
        guardian_name = _guardianName,
        guardian_phone = _guardianPhone,
        relation_of_guardian = _relationOfGuardian
    WHERE user_id = _userId;

    RETURN QUERY SELECT _userId, true, 'Student updated successfully', NULL::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT _userId::INTEGER, false, 'Unable to ' || _operationType || ' student', SQLERRM;
END;
$BODY$;
const z = require('zod');

// Schema for getting all students with optional filters
const GetStudentsSchema = z.object({
    query: z.object({
        name: z.string().optional(),
        className: z.string().optional(),
        section: z.string().optional(),
        roll: z.string().optional(),
        userId: z.string().optional(),
        roleId: z.string().optional()
    })
});

// Schema for getting a specific student by ID
const GetStudentSchema = z.object({
    params: z.object({
        id: z.string().regex(/^\d+$/, "Student ID must be a valid number")
    })
});

// Schema for adding a new student
const AddStudentSchema = z.object({
    body: z.object({
        name: z.string().min(1, "Name is required").max(100, "Name must be less than 100 characters"),
        email: z.string().email("Invalid email format"),
        phone: z.string().optional(),
        gender: z.enum(['Male', 'Female', 'Other'], {
            errorMap: () => ({ message: "Gender must be Male, Female, or Other" })
        }).optional(),
        dob: z.string().optional(),
        class: z.string().min(1, "Class is required"),
        section: z.string().min(1, "Section is required"),
        roll: z.string().min(1, "Roll number is required"),
        fatherName: z.string().optional(),
        fatherPhone: z.string().optional(),
        motherName: z.string().optional(),
        motherPhone: z.string().optional(),
        guardianName: z.string().optional(),
        guardianPhone: z.string().optional(),
        relationOfGuardian: z.string().optional(),
        currentAddress: z.string().optional(),
        permanentAddress: z.string().optional(),
        admissionDate: z.string().optional(),
        password: z.string().min(6, "Password must be at least 6 characters").optional()
    })
});

// Schema for updating a student
const UpdateStudentSchema = z.object({
    body: z.object({
        id: z.number().int().positive("Student ID is required"),
        name: z.string().min(1, "Name is required").max(100, "Name must be less than 100 characters").optional(),
        email: z.string().email("Invalid email format").optional(),
        phone: z.string().optional(),
        gender: z.enum(['Male', 'Female', 'Other'], {
            errorMap: () => ({ message: "Gender must be Male, Female, or Other" })
        }).optional(),
        dob: z.string().optional(),
        class: z.string().min(1, "Class is required").optional(),
        section: z.string().min(1, "Section is required").optional(),
        roll: z.string().min(1, "Roll number is required").optional(),
        fatherName: z.string().optional(),
        fatherPhone: z.string().optional(),
        motherName: z.string().optional(),
        motherPhone: z.string().optional(),
        guardianName: z.string().optional(),
        guardianPhone: z.string().optional(),
        relationOfGuardian: z.string().optional(),
        currentAddress: z.string().optional(),
        permanentAddress: z.string().optional(),
        admissionDate: z.string().optional()
    })
});

// Schema for updating student status
const UpdateStudentStatusSchema = z.object({
    params: z.object({
        id: z.string().regex(/^\d+$/, "Student ID must be a valid number")
    }),
    body: z.object({
        status: z.boolean({
            required_error: "Status is required",
            invalid_type_error: "Status must be a boolean"
        })
    })
});

module.exports = {
    GetStudentsSchema,
    GetStudentSchema,
    AddStudentSchema,
    UpdateStudentSchema,
    UpdateStudentStatusSchema
};

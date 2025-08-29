const express = require("express");
const router = express.Router();
const studentController = require('./students-controller');
const { validateRequest } = require('../../utils');
const {
    GetStudentsSchema,
    GetStudentSchema,
    AddStudentSchema,
    UpdateStudentSchema,
    UpdateStudentStatusSchema
} = require('./students-schema');

const { authenticateToken, csrfProtection, checkApiAccess } = require('../../middlewares');

// GET /students - Get all students with optional filters
router.get('', 
    authenticateToken, 
    csrfProtection, 
    checkApiAccess, 
    validateRequest(GetStudentsSchema), 
    studentController.handleGetAllStudents
);

// POST /students - Add new student
router.post('', 
    authenticateToken, 
    csrfProtection, 
    checkApiAccess, 
    validateRequest(AddStudentSchema), 
    studentController.handleAddStudent
);

// GET /students/:id - Get specific student details
router.get('/:id', 
    authenticateToken, 
    csrfProtection, 
    checkApiAccess, 
    validateRequest(GetStudentSchema), 
    studentController.handleGetStudentDetail
);

// PUT /students/:id - Update student
router.put('/:id', 
    authenticateToken, 
    csrfProtection, 
    checkApiAccess, 
    validateRequest(UpdateStudentSchema), 
    studentController.handleUpdateStudent
);

// POST /students/:id/status - Update student status
router.post('/:id/status', 
    authenticateToken, 
    csrfProtection, 
    checkApiAccess, 
    validateRequest(UpdateStudentStatusSchema), 
    studentController.handleStudentStatus
);

module.exports = { studentsRoutes: router };
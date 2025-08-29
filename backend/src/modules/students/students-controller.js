const asyncHandler = require('express-async-handler');
const { getAllStudents, addNewStudent, getStudentDetail, setStudentStatus, updateStudent } = require('./students-service');
const { ApiError } = require('../../utils/api-error');

const handleGetAllStudents = asyncHandler(async (req, res) => {
    try {
        const { userId, roleId, name, className, section, roll } = req.query;
        
        // Validate query parameters
        const filters = {};
        if (userId) filters.userId = userId;
        if (roleId) filters.roleId = parseInt(roleId);
        if (name) filters.name = name.trim();
        if (className) filters.className = className.trim();
        if (section) filters.section = section.trim();
        if (roll) filters.roll = roll.trim();
        
        const students = await getAllStudents(filters);
        
        res.status(200).json({ 
            success: true,
            data: students,
            count: students.length,
            message: 'Students retrieved successfully'
        });
    } catch (error) {
        console.error('Error fetching students:', error);
        throw new ApiError(500, 'Failed to retrieve students');
    }
});

const handleAddStudent = asyncHandler(async (req, res) => {
    try {
        const studentData = req.body;
        
        // Additional server-side validation
        if (!studentData.name || !studentData.email || !studentData.class || !studentData.section) {
            throw new ApiError(400, 'Required fields are missing');
        }
        
        // Sanitize input data
        const sanitizedData = {
            ...studentData,
            name: studentData.name.trim(),
            email: studentData.email.toLowerCase().trim(),
            class: studentData.class.trim(),
            section: studentData.section.trim(),
            roll: studentData.roll?.trim()
        };
        
        const result = await addNewStudent(sanitizedData);
        
        res.status(201).json({ 
            success: true,
            data: result,
            message: 'Student added successfully'
        });
    } catch (error) {
        console.error('Error adding student:', error);
        if (error instanceof ApiError) {
            throw error;
        }
        throw new ApiError(500, 'Failed to add student');
    }
});

const handleUpdateStudent = asyncHandler(async (req, res) => {
    try {
        const studentData = req.body;
        const { id } = req.params;
        
        if (!studentData.id || parseInt(studentData.id) !== parseInt(id)) {
            throw new ApiError(400, 'Student ID mismatch');
        }
        
        // Sanitize input data
        const sanitizedData = {
            ...studentData,
            name: studentData.name?.trim(),
            email: studentData.email?.toLowerCase().trim(),
            class: studentData.class?.trim(),
            section: studentData.section?.trim(),
            roll: studentData.roll?.trim()
        };
        
        const result = await updateStudent(sanitizedData);
        
        res.status(200).json({ 
            success: true,
            data: result,
            message: 'Student updated successfully'
        });
    } catch (error) {
        console.error('Error updating student:', error);
        if (error instanceof ApiError) {
            throw error;
        }
        throw new ApiError(500, 'Failed to update student');
    }
});

const handleGetStudentDetail = asyncHandler(async (req, res) => {
    try {
        const { id } = req.params;
        const studentId = parseInt(id);
        
        if (isNaN(studentId) || studentId <= 0) {
            throw new ApiError(400, 'Invalid student ID');
        }
        
        const student = await getStudentDetail(studentId);
        
        if (!student) {
            throw new ApiError(404, 'Student not found');
        }
        
        res.status(200).json({ 
            success: true,
            data: student,
            message: 'Student details retrieved successfully'
        });
    } catch (error) {
        console.error('Error fetching student details:', error);
        if (error instanceof ApiError) {
            throw error;
        }
        throw new ApiError(500, 'Failed to retrieve student details');
    }
});

const handleStudentStatus = asyncHandler(async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;
        const studentId = parseInt(id);
        
        if (isNaN(studentId) || studentId <= 0) {
            throw new ApiError(400, 'Invalid student ID');
        }
        
        if (typeof status !== 'boolean') {
            throw new ApiError(400, 'Status must be a boolean value');
        }
        
        if (!req.user || !req.user.id) {
            throw new ApiError(401, 'Unauthorized: User not authenticated');
        }
        
        const result = await setStudentStatus({ 
            userId: studentId, 
            reviewerId: req.user.id, 
            status 
        });
        
        res.status(200).json({ 
            success: true,
            data: result,
            message: `Student ${status ? 'activated' : 'deactivated'} successfully`
        });
    } catch (error) {
        console.error('Error updating student status:', error);
        if (error instanceof ApiError) {
            throw error;
        }
        throw new ApiError(500, 'Failed to update student status');
    }
});

module.exports = {
    handleGetAllStudents,
    handleGetStudentDetail,
    handleAddStudent,
    handleStudentStatus,
    handleUpdateStudent,
};
const express = require('express');
const router = express.Router();
const userService = require('../services/userService');
const { authMiddleware, adminMiddleware } = require('../middleware/auth');
const { updateUserValidation, validate } = require('../middleware/validator');
const { successResponse } = require('../utils/helpers');

/**
 * @route   GET /api/users/:userId
 * @desc    Get user by ID
 * @access  Private
 */
router.get('/:userId', authMiddleware, async (req, res, next) => {
  try {
    const { userId } = req.params;
    
    // Users can only view their own profile unless they're admin
    if (req.user.userId !== userId && req.user.role !== 'admin') {
      return res.status(403).json(errorResponse('Access denied', 403));
    }
    
    const user = await userService.getUserById(userId);
    
    res.status(200).json(successResponse(user));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   PUT /api/users/:userId
 * @desc    Update user profile
 * @access  Private
 */
router.put('/:userId', authMiddleware, updateUserValidation, validate, async (req, res, next) => {
  try {
    const { userId } = req.params;
    
    // Users can only update their own profile
    if (req.user.userId !== userId) {
      return res.status(403).json(errorResponse('Access denied', 403));
    }
    
    const user = await userService.updateUser(userId, req.body);
    
    res.status(200).json(successResponse(user, 'Profile updated successfully'));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/users
 * @desc    Get all users
 * @access  Admin only
 */
router.get('/', authMiddleware, adminMiddleware, async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 100;
    
    const users = await userService.getAllUsers(limit);
    
    res.status(200).json(successResponse(users));
  } catch (error) {
    next(error);
  }
});

module.exports = router;


const express = require('express');
const router = express.Router();
const userService = require('../services/userService');
const { authMiddleware, adminMiddleware } = require('../middleware/auth');
const { updateUserValidation, validate } = require('../middleware/validator');
const { successResponse, errorResponse } = require('../utils/helpers');

/**
 * @route   GET /api/users/me
 * @desc    Get current user profile
 * @access  Private
 */
router.get('/me', authMiddleware, async (req, res, next) => {
  try {
    const { userId } = req.user;
    const user = await userService.getUserById(userId);
    
    res.status(200).json(successResponse('User profile retrieved', user));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/users/me/orders
 * @desc    Get current user's order history
 * @access  Private
 */
router.get('/me/orders', authMiddleware, async (req, res, next) => {
  try {
    const { userId } = req.user;
    const limit = parseInt(req.query.limit) || 50;
    
    const orders = await userService.getOrderHistory(userId, limit);
    
    res.status(200).json(successResponse('Order history retrieved', {
      orders,
      count: orders.length,
    }));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   PUT /api/users/me
 * @desc    Update current user profile
 * @access  Private
 */
router.put('/me', authMiddleware, async (req, res, next) => {
  try {
    const { userId } = req.user;
    const user = await userService.updateUser(userId, req.body);
    
    res.status(200).json(successResponse('Profile updated successfully', user));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/users/me/addresses
 * @desc    Add address to user profile
 * @access  Private
 */
router.post('/me/addresses', authMiddleware, async (req, res, next) => {
  try {
    const { userId } = req.user;
    const address = req.body;

    if (!address.name || !address.address) {
      return res.status(400).json(errorResponse('Address name and address are required', 400));
    }

    const user = await userService.addAddress(userId, address);
    
    res.status(201).json(successResponse('Address added successfully', user));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   PUT /api/users/me/addresses/:index
 * @desc    Update address
 * @access  Private
 */
router.put('/me/addresses/:index', authMiddleware, async (req, res, next) => {
  try {
    const { userId } = req.user;
    const { index } = req.params;
    const address = req.body;

    const user = await userService.updateAddress(userId, parseInt(index), address);
    
    res.status(200).json(successResponse('Address updated successfully', user));
  } catch (error) {
    if (error.message === 'Invalid address index') {
      return res.status(400).json(errorResponse(error.message, 400));
    }
    next(error);
  }
});

/**
 * @route   DELETE /api/users/me/addresses/:index
 * @desc    Delete address
 * @access  Private
 */
router.delete('/me/addresses/:index', authMiddleware, async (req, res, next) => {
  try {
    const { userId } = req.user;
    const { index } = req.params;

    const user = await userService.deleteAddress(userId, parseInt(index));
    
    res.status(200).json(successResponse('Address deleted successfully', user));
  } catch (error) {
    if (error.message === 'Invalid address index') {
      return res.status(400).json(errorResponse(error.message, 400));
    }
    next(error);
  }
});

/**
 * @route   PUT /api/users/me/addresses/:index/default
 * @desc    Set default address
 * @access  Private
 */
router.put('/me/addresses/:index/default', authMiddleware, async (req, res, next) => {
  try {
    const { userId } = req.user;
    const { index } = req.params;

    const user = await userService.setDefaultAddress(userId, parseInt(index));
    
    res.status(200).json(successResponse('Default address updated', user));
  } catch (error) {
    if (error.message === 'Invalid address index') {
      return res.status(400).json(errorResponse(error.message, 400));
    }
    next(error);
  }
});

/**
 * @route   GET /api/users/:userId
 * @desc    Get user by ID
 * @access  Private (Admin or self)
 */
router.get('/:userId', authMiddleware, async (req, res, next) => {
  try {
    const { userId } = req.params;
    
    // Users can only view their own profile unless they're admin
    if (req.user.userId !== userId && req.user.role !== 'admin') {
      return res.status(403).json(errorResponse('Access denied', 403));
    }
    
    const user = await userService.getUserById(userId);
    
    res.status(200).json(successResponse('User profile retrieved', user));
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
    
    res.status(200).json(successResponse('Users retrieved', {
      users,
      count: users.length,
    }));
  } catch (error) {
    next(error);
  }
});

module.exports = router;


const express = require('express');
const router = express.Router();
const authService = require('../services/authService');
const { registerValidation, loginValidation, validate } = require('../middleware/validator');
const { successResponse, errorResponse } = require('../utils/helpers');

/**
 * @route   POST /api/auth/register
 * @desc    Register a new user
 * @access  Public
 */
router.post('/register', registerValidation, validate, async (req, res, next) => {
  try {
    const { email, password, name, phone } = req.body;
    
    const result = await authService.register(email, password, name, phone);
    
    res.status(201).json(successResponse(result, 'User registered successfully'));
  } catch (error) {
    if (error.message.includes('already exists')) {
      return res.status(409).json(errorResponse(error.message, 409));
    }
    next(error);
  }
});

/**
 * @route   POST /api/auth/login
 * @desc    Login user
 * @access  Public
 */
router.post('/login', loginValidation, validate, async (req, res, next) => {
  try {
    const { email, password } = req.body;
    
    const result = await authService.login(email, password);
    
    res.status(200).json(successResponse(result, 'Login successful'));
  } catch (error) {
    if (error.message.includes('Invalid')) {
      return res.status(401).json(errorResponse(error.message, 401));
    }
    next(error);
  }
});

module.exports = router;


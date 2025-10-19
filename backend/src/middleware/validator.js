const { body, param, validationResult } = require('express-validator');
const { errorResponse } = require('../utils/helpers');

/**
 * Middleware to check validation results
 */
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json(
      errorResponse('Validation failed', 400, errors.array())
    );
  }
  next();
};

// Auth validation rules
const registerValidation = [
  body('email')
    .isEmail()
    .withMessage('Valid email is required')
    .normalizeEmail(),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters'),
  body('name')
    .trim()
    .notEmpty()
    .withMessage('Name is required'),
  body('phone')
    .matches(/^[0-9]{10}$/)
    .withMessage('Valid phone number is required (10 digits)'),
];

const loginValidation = [
  body('email')
    .isEmail()
    .withMessage('Valid email is required')
    .normalizeEmail(),
  body('password')
    .notEmpty()
    .withMessage('Password is required'),
];

// Order validation rules
const createOrderValidation = [
  body('storeId')
    .notEmpty()
    .withMessage('Store ID is required'),
  body('items')
    .isArray({ min: 1 })
    .withMessage('Order must contain at least one item'),
  body('items.*.productId')
    .notEmpty()
    .withMessage('Product ID is required for each item'),
  body('items.*.quantity')
    .isInt({ min: 1 })
    .withMessage('Quantity must be at least 1'),
  body('paymentMethod')
    .isIn(['card', 'cash', 'momo', 'zalopay'])
    .withMessage('Invalid payment method'),
];

// User update validation
const updateUserValidation = [
  body('name')
    .optional()
    .trim()
    .notEmpty()
    .withMessage('Name cannot be empty'),
  body('phone')
    .optional()
    .matches(/^[0-9]{10}$/)
    .withMessage('Valid phone number is required (10 digits)'),
];

module.exports = {
  validate,
  registerValidation,
  loginValidation,
  createOrderValidation,
  updateUserValidation,
};


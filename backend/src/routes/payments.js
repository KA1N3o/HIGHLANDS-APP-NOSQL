const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');
const { successResponse, errorResponse } = require('../utils/helpers');

/**
 * @route   POST /api/payments
 * @desc    Process payment for an order
 * @access  Private
 */
router.post('/', authMiddleware, async (req, res, next) => {
  try {
    const { orderId, method, details } = req.body;
    
    // Validate payment method
    const validMethods = ['card', 'cash', 'momo', 'zalopay'];
    if (!validMethods.includes(method)) {
      return res.status(400).json(errorResponse('Invalid payment method', 400));
    }
    
    // In a real application, you would integrate with payment gateways here
    // For now, we'll simulate a successful payment
    
    const paymentResult = {
      orderId,
      method,
      status: method === 'cash' ? 'pending' : 'paid',
      transactionId: `txn_${Date.now()}`,
      timestamp: new Date().toISOString(),
    };
    
    res.status(200).json(
      successResponse(paymentResult, 'Payment processed successfully')
    );
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/payments/:orderId
 * @desc    Get payment status for an order
 * @access  Private
 */
router.get('/:orderId', authMiddleware, async (req, res, next) => {
  try {
    const { orderId } = req.params;
    
    // In a real application, you would query the payment status from the database
    // For now, return a mock response
    
    const paymentStatus = {
      orderId,
      status: 'paid',
      method: 'card',
      timestamp: new Date().toISOString(),
    };
    
    res.status(200).json(successResponse(paymentStatus));
  } catch (error) {
    next(error);
  }
});

module.exports = router;


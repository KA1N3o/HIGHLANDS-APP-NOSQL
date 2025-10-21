const express = require('express');
const router = express.Router();
const orderService = require('../services/orderService');
const { authMiddleware, adminMiddleware, staffMiddleware } = require('../middleware/auth');
const { createOrderValidation, validate } = require('../middleware/validator');
const { successResponse, errorResponse } = require('../utils/helpers');

/**
 * @route   POST /api/orders
 * @desc    Create a new order
 * @access  Private
 */
router.post('/', authMiddleware, createOrderValidation, validate, async (req, res, next) => {
  try {
    const userId = req.user.userId;
    
    const order = await orderService.createOrder(userId, req.body);
    
    res.status(201).json(successResponse(order, 'Order created successfully'));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/orders/user/:userId
 * @desc    Get orders for a specific user
 * @access  Private
 */
router.get('/user/:userId', authMiddleware, async (req, res, next) => {
  try {
    const { userId } = req.params;
    
    console.log(`GET /api/orders/user/${userId} - JWT userId: ${req.user.userId}, role: ${req.user.role}`);
    
    // Users can only view their own orders unless they're admin
    // Normalize both IDs for comparison (remove any whitespace/case issues)
    const tokenUserId = String(req.user.userId).trim();
    const paramUserId = String(userId).trim();
    
    if (tokenUserId !== paramUserId && req.user.role !== 'admin') {
      console.log(`Access denied: token='${tokenUserId}' !== param='${paramUserId}'`);
      return res.status(403).json(errorResponse('Access denied', 403));
    }
    
    const limit = parseInt(req.query.limit) || 50;
    const orders = await orderService.getUserOrders(paramUserId, limit);
    
    res.status(200).json(successResponse(orders));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/orders/:orderId
 * @desc    Get order by ID
 * @access  Private
 */
router.get('/:orderId', authMiddleware, async (req, res, next) => {
  try {
    const { orderId } = req.params;
    
    const order = await orderService.getOrderById(orderId);
    
    // Users can only view their own orders unless they're admin
    if (order.userId !== req.user.userId && req.user.role !== 'admin') {
      return res.status(403).json(errorResponse('Access denied', 403));
    }
    
    res.status(200).json(successResponse(order));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   PATCH /api/orders/:orderId/status
 * @desc    Update order status
 * @access  Staff and Admin
 */
router.patch('/:orderId/status', authMiddleware, staffMiddleware, async (req, res, next) => {
  try {
    const { orderId } = req.params;
    const { status } = req.body;
    
    const validStatuses = ['pending', 'confirmed', 'preparing', 'ready', 'delivering', 'completed', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json(errorResponse('Invalid status', 400));
    }
    
    const order = await orderService.updateOrderStatus(orderId, status);
    
    res.status(200).json(successResponse(order, 'Order status updated'));
  } catch (error) {
    if (error.message === 'Order not found') {
      return res.status(404).json(errorResponse(error.message, 404));
    }
    next(error);
  }
});

/**
 * @route   POST /api/orders/:orderId/cancel
 * @desc    Cancel order
 * @access  Private
 */
router.post('/:orderId/cancel', authMiddleware, async (req, res, next) => {
  try {
    const { orderId } = req.params;
    const { userId } = req.user;
    const { reason } = req.body;
    
    const order = await orderService.cancelOrder(orderId, userId, reason);
    
    res.status(200).json(successResponse(order, 'Order cancelled successfully'));
  } catch (error) {
    if (error.message === 'Order not found') {
      return res.status(404).json(errorResponse(error.message, 404));
    }
    if (error.message.includes('cannot be cancelled') || error.message.includes('Unauthorized')) {
      return res.status(400).json(errorResponse(error.message, 400));
    }
    next(error);
  }
});

/**
 * @route   PATCH /api/orders/:orderId/payment
 * @desc    Update payment status
 * @access  Private (Admin or payment gateway callback)
 */
router.patch('/:orderId/payment', authMiddleware, async (req, res, next) => {
  try {
    const { orderId } = req.params;
    const { paymentStatus } = req.body;
    
    const validStatuses = ['pending', 'paid', 'failed', 'refunded'];
    if (!validStatuses.includes(paymentStatus)) {
      return res.status(400).json(errorResponse('Invalid payment status', 400));
    }
    
    const order = await orderService.updatePaymentStatus(orderId, paymentStatus);
    
    res.status(200).json(successResponse(order, 'Payment status updated'));
  } catch (error) {
    if (error.message === 'Order not found') {
      return res.status(404).json(errorResponse(error.message, 404));
    }
    next(error);
  }
});

/**
 * @route   GET /api/orders
 * @desc    Get all orders
 * @access  Staff and Admin
 */
router.get('/', authMiddleware, staffMiddleware, async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 100;
    
    const orders = await orderService.getAllOrders(limit);
    
    res.status(200).json(successResponse({
      orders,
      count: orders.length,
    }, 'Orders retrieved'));
  } catch (error) {
    next(error);
  }
});

module.exports = router;


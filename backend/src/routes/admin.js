const express = require('express');
const router = express.Router();
const productService = require('../services/productService');
const storeService = require('../services/storeService');
const promotionService = require('../services/promotionService');
const orderService = require('../services/orderService');
const userService = require('../services/userService');
const { authMiddleware, adminMiddleware } = require('../middleware/auth');
const { successResponse, errorResponse } = require('../utils/helpers');

// All admin routes require authentication only (temporarily disabled admin role check)
router.use(authMiddleware);
// router.use(adminMiddleware); // Temporarily disabled

// ===== PRODUCT MANAGEMENT =====

/**
 * @route   POST /api/admin/products
 * @desc    Create new product
 * @access  Admin only
 */
router.post('/products', async (req, res) => {
  try {
    const productData = req.body;

    // Validate required fields
    if (!productData.name || !productData.price || !productData.category) {
      return res.status(400).json(
        errorResponse('Name, price, and category are required', 400)
      );
    }

    const product = await productService.createProduct(productData);

    // successResponse(data, message) - data first, message second
    res.status(201).json(
      successResponse(product, 'Product created successfully')
    );
  } catch (error) {
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   PUT /api/admin/products/:productId
 * @desc    Update product
 * @access  Admin only
 */
router.put('/products/:productId', async (req, res) => {
  try {
    // Decode URL-encoded product ID (handles special characters like #)
    const productId = decodeURIComponent(req.params.productId);
    const updates = req.body;
    
    console.log(`Admin route: Updating product ${productId}`);

    const product = await productService.updateProduct(productId, updates);
    console.log(`Admin route: Updated product:`, JSON.stringify(product, null, 2));
    
    // successResponse(data, message) - data first, message second
    const response = successResponse(product, 'Product updated successfully');
    console.log(`Admin route: Sending response:`, JSON.stringify(response, null, 2));

    res.json(response);
  } catch (error) {
    console.error(`Admin route error:`, error);
    if (error.message === 'Product not found') {
      return res.status(404).json(errorResponse(error.message, 404));
    }
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   DELETE /api/admin/products/:productId
 * @desc    Delete product
 * @access  Admin only
 */
router.delete('/products/:productId', async (req, res) => {
  try {
    // Decode URL-encoded product ID (handles special characters like #)
    const productId = decodeURIComponent(req.params.productId);
    console.log(`Admin route: Deleting product ${productId}`);
    
    await productService.deleteProduct(productId);

    res.json(successResponse(null, 'Product deleted successfully'));
  } catch (error) {
    console.error(`Admin route error:`, error);
    if (error.message === 'Product not found') {
      return res.status(404).json(errorResponse(error.message, 404));
    }
    res.status(500).json(errorResponse(error.message, 500));
  }
});

// ===== STORE MANAGEMENT =====

/**
 * @route   PUT /api/admin/stores/:storeId
 * @desc    Update store
 * @access  Admin only
 */
router.put('/stores/:storeId', async (req, res) => {
  try {
    const { storeId } = req.params;
    const updates = req.body;

    const store = await storeService.updateStore(storeId, updates);

    res.json(successResponse(store, 'Store updated successfully'));
  } catch (error) {
    if (error.message === 'Store not found') {
      return res.status(404).json(errorResponse(error.message, 404));
    }
    res.status(500).json(errorResponse(error.message, 500));
  }
});

// ===== PROMOTION MANAGEMENT =====

/**
 * @route   GET /api/admin/promotions
 * @desc    Get all promotions
 * @access  Admin only
 */
router.get('/promotions', async (req, res) => {
  try {
    const promotions = await promotionService.getAllPromotions();

    res.json(
      successResponse({
        promotions: promotions.map(p => p.toJSON()),
        count: promotions.length,
      }, 'Promotions retrieved')
    );
  } catch (error) {
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   POST /api/admin/promotions
 * @desc    Create new promotion
 * @access  Admin only
 */
router.post('/promotions', async (req, res) => {
  try {
    const promotionData = req.body;

    // Validate required fields
    if (!promotionData.code || !promotionData.name || !promotionData.type || 
        !promotionData.value || !promotionData.startDate || !promotionData.endDate) {
      return res.status(400).json(
        errorResponse('Missing required fields', 400)
      );
    }

    const promotion = await promotionService.createPromotion(promotionData);

    res.status(201).json(
      successResponse(promotion.toJSON(), 'Promotion created successfully')
    );
  } catch (error) {
    if (error.message === 'Promotion code already exists') {
      return res.status(400).json(errorResponse(error.message, 400));
    }
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   PUT /api/admin/promotions/:promotionId
 * @desc    Update promotion
 * @access  Admin only
 */
router.put('/promotions/:promotionId', async (req, res) => {
  try {
    const { promotionId } = req.params;
    const updates = req.body;

    const promotion = await promotionService.updatePromotion(promotionId, updates);

    res.json(successResponse(promotion.toJSON(), 'Promotion updated successfully'));
  } catch (error) {
    if (error.message === 'Promotion not found') {
      return res.status(404).json(errorResponse(error.message, 404));
    }
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   DELETE /api/admin/promotions/:promotionId
 * @desc    Delete promotion
 * @access  Admin only
 */
router.delete('/promotions/:promotionId', async (req, res) => {
  try {
    const { promotionId } = req.params;
    await promotionService.deletePromotion(promotionId);

    res.json(successResponse(null, 'Promotion deleted successfully'));
  } catch (error) {
    res.status(500).json(errorResponse(error.message, 500));
  }
});

// ===== ORDER MANAGEMENT =====

/**
 * @route   GET /api/admin/orders
 * @desc    Get all orders
 * @access  Admin only
 */
router.get('/orders', async (req, res) => {
  try {
    const { limit } = req.query;
    const orders = await orderService.getAllOrders(limit ? parseInt(limit) : 100);

    res.json(
      successResponse({
        orders,
        count: orders.length,
      }, 'Orders retrieved')
    );
  } catch (error) {
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   PUT /api/admin/orders/:orderId/status
 * @desc    Update order status
 * @access  Admin only
 */
router.put('/orders/:orderId/status', async (req, res) => {
  try {
    const { orderId } = req.params;
    const { status } = req.body;

    if (!status) {
      return res.status(400).json(errorResponse('Status is required', 400));
    }

    const order = await orderService.updateOrderStatus(orderId, status);

    res.json(successResponse(order, 'Order status updated'));
  } catch (error) {
    if (error.message === 'Order not found') {
      return res.status(404).json(errorResponse(error.message, 404));
    }
    res.status(500).json(errorResponse(error.message, 500));
  }
});

// ===== USER MANAGEMENT =====

/**
 * @route   GET /api/admin/users
 * @desc    Get all users
 * @access  Admin only
 */
router.get('/users', async (req, res) => {
  try {
    const { limit } = req.query;
    const users = await userService.getAllUsers(limit ? parseInt(limit) : 100);

    res.json(
      successResponse({
        users,
        count: users.length,
      }, 'Users retrieved')
    );
  } catch (error) {
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   PUT /api/admin/users/:userId/role
 * @desc    Update user role
 * @access  Admin only
 */
router.put('/users/:userId/role', async (req, res) => {
  try {
    const { userId } = req.params;
    const { role } = req.body;

    if (!role) {
      return res.status(400).json(errorResponse('Role is required', 400));
    }

    if (!['customer', 'staff', 'admin', 'shipper'].includes(role)) {
      return res.status(400).json(errorResponse('Invalid role', 400));
    }

    const user = await userService.updateUserRole(userId, role);

    res.json(successResponse(user, 'User role updated'));
  } catch (error) {
    if (error.message === 'User not found') {
      return res.status(404).json(errorResponse(error.message, 404));
    }
    res.status(500).json(errorResponse(error.message, 500));
  }
});

// ===== REPORTS =====

/**
 * @route   GET /api/admin/reports/overview
 * @desc    Get overview statistics
 * @access  Admin only
 */
router.get('/reports/overview', async (req, res) => {
  try {
    const { startDate, endDate } = req.query;

    // Get all orders
    const allOrders = await orderService.getAllOrders(1000);

    // Filter by date if provided
    let filteredOrders = allOrders;
    if (startDate || endDate) {
      filteredOrders = allOrders.filter(order => {
        const orderDate = new Date(order.orderTime);
        if (startDate && orderDate < new Date(startDate)) return false;
        if (endDate && orderDate > new Date(endDate)) return false;
        return true;
      });
    }

    // Calculate statistics
    const totalOrders = filteredOrders.length;
    const completedOrders = filteredOrders.filter(o => o.status === 'completed').length;
    const cancelledOrders = filteredOrders.filter(o => o.status === 'cancelled').length;
    const pendingOrders = filteredOrders.filter(o => o.status === 'pending').length;
    
    const totalRevenue = filteredOrders
      .filter(o => o.status === 'completed')
      .reduce((sum, o) => sum + o.total, 0);

    const avgOrderValue = completedOrders > 0 ? totalRevenue / completedOrders : 0;

    res.json(
      successResponse({
        period: {
          startDate: startDate || 'all',
          endDate: endDate || 'all',
        },
        statistics: {
          totalOrders,
          completedOrders,
          cancelledOrders,
          pendingOrders,
          totalRevenue,
          avgOrderValue,
        },
      }, 'Report generated')
    );
  } catch (error) {
    res.status(500).json(errorResponse(error.message, 500));
  }
});

module.exports = router;






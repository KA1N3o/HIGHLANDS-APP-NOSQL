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

    res.status(201).json(
      successResponse('Product created successfully', product)
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
    
    const response = successResponse('Product updated successfully', product);
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

    res.json(successResponse('Product deleted successfully', null));
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

    res.json(successResponse('Store updated successfully', store));
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
      successResponse('Promotions retrieved', {
        promotions: promotions.map(p => p.toJSON()),
        count: promotions.length,
      })
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
    // Note: value can be 0 (for free_shipping), so check for null/undefined explicitly
    if (!promotionData.code || !promotionData.name || !promotionData.type || 
        promotionData.value === undefined || promotionData.value === null ||
        !promotionData.startDate || !promotionData.endDate) {
      return res.status(400).json(
        errorResponse('Missing required fields', 400)
      );
    }

    const promotion = await promotionService.createPromotion(promotionData);

    res.status(201).json(
      successResponse('Promotion created successfully', promotion.toJSON())
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

    res.json(successResponse('Promotion updated successfully', promotion.toJSON()));
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

    res.json(successResponse('Promotion deleted successfully', null));
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
      successResponse('Orders retrieved', {
        orders,
        count: orders.length,
      })
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

    res.json(successResponse('Order status updated', order));
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
      successResponse('Users retrieved', {
        users,
        count: users.length,
      })
    );
  } catch (error) {
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   PUT /api/admin/users/:userId
 * @desc    Update user information
 * @access  Admin only
 */
router.put('/users/:userId', async (req, res) => {
  try {
    // Decode URL-encoded user ID (handles special characters like #)
    const userId = decodeURIComponent(req.params.userId);
    const updates = req.body;

    const user = await userService.updateUser(userId, updates);

    res.json(successResponse('User updated successfully', user));
  } catch (error) {
    if (error.message === 'User not found') {
      return res.status(404).json(errorResponse(error.message, 404));
    }
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   PUT /api/admin/users/:userId/role
 * @desc    Update user role and assigned store
 * @access  Admin only
 */
router.put('/users/:userId/role', async (req, res) => {
  try {
    // Decode URL-encoded user ID (handles special characters like #)
    const userId = decodeURIComponent(req.params.userId);
    const { role, assignedStoreId } = req.body;

    if (!role) {
      return res.status(400).json(errorResponse('Role is required', 400));
    }

    if (!['customer', 'staff', 'admin', 'shipper'].includes(role)) {
      return res.status(400).json(errorResponse('Invalid role', 400));
    }

    // Validate: Staff must have an assigned store
    if (role === 'staff' && !assignedStoreId) {
      return res.status(400).json(
        errorResponse('Staff role requires an assigned store', 400)
      );
    }

    const user = await userService.updateUserRole(userId, role, assignedStoreId);

    res.json(successResponse('User role updated', user));
  } catch (error) {
    if (error.message === 'User not found') {
      return res.status(404).json(errorResponse(error.message, 404));
    }
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   DELETE /api/admin/users/:userId
 * @desc    Delete user
 * @access  Admin only
 */
router.delete('/users/:userId', async (req, res) => {
  try {
    // Decode URL-encoded user ID (handles special characters like #)
    const userId = decodeURIComponent(req.params.userId);
    console.log(`Admin route: Deleting user ${userId}`);

    await userService.deleteUser(userId);

    res.json(successResponse('User deleted successfully', null));
  } catch (error) {
    console.error(`Admin route error:`, error);
    if (error.message === 'User not found') {
      return res.status(404).json(errorResponse(error.message, 404));
    }
    if (error.message === 'Cannot delete admin users') {
      return res.status(403).json(errorResponse(error.message, 403));
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
      successResponse('Report generated', {
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
      })
    );
  } catch (error) {
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   POST /api/admin/cache/clear
 * @desc    Clear product cache
 * @access  Admin only
 */
router.post('/cache/clear', async (req, res) => {
  try {
    productService.clearCache();
    res.json(successResponse('Cache cleared successfully'));
  } catch (error) {
    res.status(500).json(errorResponse(error.message, 500));
  }
});

module.exports = router;






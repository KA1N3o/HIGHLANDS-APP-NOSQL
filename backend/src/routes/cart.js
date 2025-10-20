const express = require('express');
const router = express.Router();
const cartService = require('../services/cartService');
const productService = require('../services/productService');
const { authMiddleware } = require('../middleware/auth');
const { successResponse, errorResponse } = require('../utils/helpers');

// All cart routes require authentication
router.use(authMiddleware);

/**
 * @route   GET /api/cart
 * @desc    Get user's cart
 * @access  Private
 */
router.get('/', async (req, res) => {
  try {
    const { userId } = req.user;
    const cart = await cartService.getCart(userId);

    res.json(successResponse('Cart retrieved successfully', cart.toJSON()));
  } catch (error) {
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   POST /api/cart/items
 * @desc    Add item to cart
 * @access  Private
 */
router.post('/items', async (req, res) => {
  try {
    const { userId } = req.user;
    const { productId, quantity, size, options, note } = req.body;

    // Validate required fields
    if (!productId || !quantity) {
      return res.status(400).json(
        errorResponse('Product ID and quantity are required', 400)
      );
    }

    // Get product details
    const product = await productService.getProductById(productId);

    if (!product.isAvailable) {
      return res.status(400).json(
        errorResponse('Product is not available', 400)
      );
    }

    // Create cart item
    const item = {
      productId,
      productName: product.name,
      price: product.price,
      quantity,
      size: size || 'Medium',
      options: options || {},
      imageUrl: product.imageUrl,
      note: note || '',
    };

    const cart = await cartService.addItem(userId, item);

    res.status(201).json(
      successResponse('Item added to cart successfully', cart.toJSON())
    );
  } catch (error) {
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   PUT /api/cart/items/:index
 * @desc    Update cart item quantity
 * @access  Private
 */
router.put('/items/:index', async (req, res) => {
  try {
    const { userId } = req.user;
    const { index } = req.params;
    const { quantity } = req.body;

    if (quantity === undefined) {
      return res.status(400).json(
        errorResponse('Quantity is required', 400)
      );
    }

    const cart = await cartService.updateItem(
      userId,
      parseInt(index),
      parseInt(quantity)
    );

    res.json(successResponse('Cart updated successfully', cart.toJSON()));
  } catch (error) {
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   DELETE /api/cart/items/:index
 * @desc    Remove item from cart
 * @access  Private
 */
router.delete('/items/:index', async (req, res) => {
  try {
    const { userId } = req.user;
    const { index } = req.params;

    const cart = await cartService.removeItem(userId, parseInt(index));

    res.json(successResponse('Item removed from cart', cart.toJSON()));
  } catch (error) {
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   DELETE /api/cart
 * @desc    Clear cart
 * @access  Private
 */
router.delete('/', async (req, res) => {
  try {
    const { userId } = req.user;
    const cart = await cartService.clearCart(userId);

    res.json(successResponse('Cart cleared successfully', cart.toJSON()));
  } catch (error) {
    res.status(500).json(errorResponse(error.message, 500));
  }
});

module.exports = router;







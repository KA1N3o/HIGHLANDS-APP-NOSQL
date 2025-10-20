const express = require('express');
const router = express.Router();
const productService = require('../services/productService');
const { authMiddleware } = require('../middleware/auth');
const { successResponse, errorResponse } = require('../utils/helpers');

/**
 * @route   GET /api/products
 * @desc    Get all products
 * @access  Private
 */
router.get('/', authMiddleware, async (req, res, next) => {
  try {
    const { category, available } = req.query;
    const availableOnly = available === 'true';
    
    let products;
    if (category) {
      products = await productService.getProductsByCategory(category, availableOnly);
    } else {
      products = await productService.getAllProducts(availableOnly);
    }
    
    res.status(200).json(successResponse('Products retrieved', {
      products,
      count: products.length,
    }));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/products/search
 * @desc    Search products by keyword
 * @access  Private
 */
router.get('/search', authMiddleware, async (req, res, next) => {
  try {
    const { q, available } = req.query;
    
    if (!q) {
      return res.status(400).json(errorResponse('Search query is required', 400));
    }

    const availableOnly = available === 'true';
    const products = await productService.searchProducts(q, availableOnly);
    
    res.status(200).json(successResponse('Search results', {
      products,
      count: products.length,
      query: q,
    }));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/products/categories
 * @desc    Get list of categories
 * @access  Private
 */
router.get('/categories', authMiddleware, async (req, res, next) => {
  try {
    const categories = [
      { id: 'coffee', name: 'Cà phê', icon: '☕' },
      { id: 'tea', name: 'Trà', icon: '🍵' },
      { id: 'smoothie', name: 'Sinh tố', icon: '🥤' },
      { id: 'food', name: 'Đồ ăn', icon: '🍔' },
      { id: 'pastry', name: 'Bánh ngọt', icon: '🧁' },
    ];
    
    res.status(200).json(successResponse('Categories retrieved', categories));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/products/:productId
 * @desc    Get product by ID
 * @access  Private
 */
router.get('/:productId', authMiddleware, async (req, res, next) => {
  try {
    const { productId } = req.params;
    
    const product = await productService.getProductById(productId);
    
    res.status(200).json(successResponse('Product retrieved', product));
  } catch (error) {
    if (error.message === 'Product not found') {
      return res.status(404).json(errorResponse(error.message, 404));
    }
    next(error);
  }
});

module.exports = router;


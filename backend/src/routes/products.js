const express = require('express');
const router = express.Router();
const productService = require('../services/productService');
const { authMiddleware } = require('../middleware/auth');
const { successResponse } = require('../utils/helpers');

/**
 * @route   GET /api/products
 * @desc    Get all products
 * @access  Private
 */
router.get('/', authMiddleware, async (req, res, next) => {
  try {
    const { category } = req.query;
    
    let products;
    if (category) {
      products = await productService.getProductsByCategory(category);
    } else {
      products = await productService.getAllProducts();
    }
    
    res.status(200).json(successResponse(products));
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
    
    res.status(200).json(successResponse(product));
  } catch (error) {
    next(error);
  }
});

module.exports = router;


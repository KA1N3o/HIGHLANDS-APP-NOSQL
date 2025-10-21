const express = require('express');
const router = express.Router();
const promotionService = require('../services/promotionService');
const { authMiddleware } = require('../middleware/auth');
const { successResponse, errorResponse } = require('../utils/helpers');

/**
 * @route   GET /api/promotions
 * @desc    Get all active promotions
 * @access  Private
 */
router.get('/', authMiddleware, async (req, res) => {
  try {
    const promotions = await promotionService.getAllPromotions(true);

    res.json(
      successResponse('Active promotions retrieved', {
        promotions: promotions.map(p => p.toJSON()),
        count: promotions.length,
      })
    );
  } catch (error) {
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   GET /api/promotions/:code
 * @desc    Get promotion by code
 * @access  Private
 */
router.get('/:code', authMiddleware, async (req, res) => {
  try {
    const { code } = req.params;
    const promotion = await promotionService.getPromotionByCode(code);

    res.json(
      successResponse('Promotion retrieved', promotion.toJSON())
    );
  } catch (error) {
    if (error.message === 'Promotion not found') {
      return res.status(404).json(errorResponse(error.message, 404));
    }
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   POST /api/promotions/validate
 * @desc    Validate and apply promotion code
 * @access  Private
 */
router.post('/validate', authMiddleware, async (req, res) => {
  try {
    const { code, orderValue } = req.body;

    if (!code || orderValue === undefined) {
      return res.status(400).json(
        errorResponse('Code and order value are required', 400)
      );
    }

    const result = await promotionService.applyPromotion(code, orderValue);

    res.json(
      successResponse('Promotion is valid', result)
    );
  } catch (error) {
    if (error.message.includes('not valid') || error.message.includes('not meet')) {
      return res.status(400).json(errorResponse(error.message, 400));
    }
    if (error.message === 'Promotion not found') {
      return res.status(404).json(errorResponse(error.message, 404));
    }
    res.status(500).json(errorResponse(error.message, 500));
  }
});

module.exports = router;









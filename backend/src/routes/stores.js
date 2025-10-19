const express = require('express');
const router = express.Router();
const storeService = require('../services/storeService');
const { authMiddleware } = require('../middleware/auth');
const { successResponse } = require('../utils/helpers');

/**
 * @route   GET /api/stores
 * @desc    Get all stores or nearby stores
 * @access  Private
 */
router.get('/', authMiddleware, async (req, res, next) => {
  try {
    const { lat, lon, radius } = req.query;
    
    let stores;
    if (lat && lon) {
      const latitude = parseFloat(lat);
      const longitude = parseFloat(lon);
      const radiusKm = radius ? parseFloat(radius) : 10;
      
      stores = await storeService.getNearbyStores(latitude, longitude, radiusKm);
    } else {
      stores = await storeService.getAllStores();
    }
    
    res.status(200).json(successResponse(stores));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/stores/:storeId
 * @desc    Get store by ID
 * @access  Private
 */
router.get('/:storeId', authMiddleware, async (req, res, next) => {
  try {
    const { storeId } = req.params;
    
    const store = await storeService.getStoreById(storeId);
    
    res.status(200).json(successResponse(store));
  } catch (error) {
    next(error);
  }
});

module.exports = router;


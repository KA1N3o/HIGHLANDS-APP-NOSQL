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
    const user = req.user; // Get authenticated user from middleware
    
    let stores;
    if (lat && lon) {
      const latitude = parseFloat(lat);
      const longitude = parseFloat(lon);
      const radiusKm = radius ? parseFloat(radius) : 10;
      
      stores = await storeService.getNearbyStores(latitude, longitude, radiusKm);
    } else {
      stores = await storeService.getAllStores();
    }
    
    // Filter stores based on user role
    // If user is staff with assigned store, only return that store
    if (user.role === 'staff' && user.assignedStoreId) {
      stores = stores.filter(store => store.id === user.assignedStoreId);
    }
    // Admin and customers can see all stores
    
    res.status(200).json(successResponse('Stores retrieved', stores));
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
    
    res.status(200).json(successResponse('Store retrieved', store));
  } catch (error) {
    next(error);
  }
});

module.exports = router;


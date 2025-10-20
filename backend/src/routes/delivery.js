const express = require('express');
const router = express.Router();
const deliveryService = require('../services/deliveryService');
const { authMiddleware, shipperMiddleware, roleMiddleware } = require('../middleware/auth');
const { successResponse, errorResponse } = require('../utils/helpers');

/**
 * @route   GET /api/delivery/order/:orderId
 * @desc    Get delivery info by order ID
 * @access  Private
 */
router.get('/order/:orderId', authMiddleware, async (req, res) => {
  try {
    const { orderId } = req.params;
    const delivery = await deliveryService.getDeliveryByOrderId(orderId);

    res.json(successResponse('Delivery info retrieved', delivery.toJSON()));
  } catch (error) {
    if (error.message === 'Delivery not found') {
      return res.status(404).json(errorResponse(error.message, 404));
    }
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   GET /api/delivery/shipper
 * @desc    Get deliveries for authenticated shipper
 * @access  Shipper only
 */
router.get('/shipper', authMiddleware, shipperMiddleware, async (req, res) => {
  try {
    const { userId } = req.user;
    const { status } = req.query;

    const deliveries = await deliveryService.getShipperDeliveries(userId, status);

    res.json(
      successResponse('Shipper deliveries retrieved', {
        deliveries: deliveries.map(d => d.toJSON()),
        count: deliveries.length,
      })
    );
  } catch (error) {
    res.status(500).json(errorResponse(error.message, 500));
  }
});

/**
 * @route   PUT /api/delivery/:deliveryId/status
 * @desc    Update delivery status
 * @access  Shipper/Admin only
 */
router.put(
  '/:deliveryId/status',
  authMiddleware,
  roleMiddleware('shipper', 'admin'),
  async (req, res) => {
    try {
      const { deliveryId } = req.params;
      const { status, location, failureReason } = req.body;

      if (!status) {
        return res.status(400).json(errorResponse('Status is required', 400));
      }

      const additionalData = {};
      
      if (location) {
        additionalData.currentLocation = location;
      }

      if (status === 'delivered') {
        additionalData.actualDeliveryTime = new Date().toISOString();
      }

      if (status === 'failed' && failureReason) {
        additionalData.failureReason = failureReason;
      }

      const delivery = await deliveryService.updateDeliveryStatus(
        deliveryId,
        status,
        additionalData
      );

      res.json(successResponse('Delivery status updated', delivery.toJSON()));
    } catch (error) {
      if (error.message === 'Delivery not found') {
        return res.status(404).json(errorResponse(error.message, 404));
      }
      res.status(500).json(errorResponse(error.message, 500));
    }
  }
);

/**
 * @route   PUT /api/delivery/:deliveryId/location
 * @desc    Update delivery location
 * @access  Shipper only
 */
router.put(
  '/:deliveryId/location',
  authMiddleware,
  shipperMiddleware,
  async (req, res) => {
    try {
      const { deliveryId } = req.params;
      const { lat, lng } = req.body;

      if (!lat || !lng) {
        return res.status(400).json(
          errorResponse('Latitude and longitude are required', 400)
        );
      }

      const delivery = await deliveryService.updateLocation(deliveryId, {
        lat,
        lng,
      });

      res.json(successResponse('Location updated', delivery.toJSON()));
    } catch (error) {
      if (error.message === 'Delivery not found') {
        return res.status(404).json(errorResponse(error.message, 404));
      }
      res.status(500).json(errorResponse(error.message, 500));
    }
  }
);

/**
 * @route   PUT /api/delivery/:deliveryId/assign
 * @desc    Assign shipper to delivery
 * @access  Admin only
 */
router.put(
  '/:deliveryId/assign',
  authMiddleware,
  roleMiddleware('admin'),
  async (req, res) => {
    try {
      const { deliveryId } = req.params;
      const { shipperId, shipperName, shipperPhone } = req.body;

      if (!shipperId || !shipperName || !shipperPhone) {
        return res.status(400).json(
          errorResponse('Shipper information is required', 400)
        );
      }

      const delivery = await deliveryService.assignShipper(
        deliveryId,
        shipperId,
        shipperName,
        shipperPhone
      );

      res.json(successResponse('Shipper assigned', delivery.toJSON()));
    } catch (error) {
      if (error.message === 'Delivery not found') {
        return res.status(404).json(errorResponse(error.message, 404));
      }
      res.status(500).json(errorResponse(error.message, 500));
    }
  }
);

module.exports = router;







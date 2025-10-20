const { v4: uuidv4 } = require('uuid');
const { parseRowData, decodeEscapedUTF8 } = require('../utils/helpers');

class Delivery {
  constructor(data) {
    this.id = data.id || `delivery#${uuidv4()}`;
    this.orderId = data.orderId || '';
    this.shipperId = data.shipperId || null;
    this.shipperName = data.shipperName || null;
    this.shipperPhone = data.shipperPhone || null;
    this.status = data.status || 'pending'; // pending, assigned, picking_up, delivering, delivered, failed
    this.pickupAddress = data.pickupAddress || {};
    this.deliveryAddress = data.deliveryAddress || {};
    this.currentLocation = data.currentLocation || null; // { lat, lng, timestamp }
    this.estimatedDeliveryTime = data.estimatedDeliveryTime || null;
    this.actualDeliveryTime = data.actualDeliveryTime || null;
    this.notes = data.notes || '';
    this.failureReason = data.failureReason || null;
    this.createdAt = data.createdAt || new Date().toISOString();
    this.updatedAt = data.updatedAt || new Date().toISOString();
  }

  updateStatus(status, additionalData = {}) {
    this.status = status;
    this.updatedAt = new Date().toISOString();

    if (status === 'delivered' && additionalData.actualDeliveryTime) {
      this.actualDeliveryTime = additionalData.actualDeliveryTime;
    }

    if (status === 'failed' && additionalData.failureReason) {
      this.failureReason = additionalData.failureReason;
    }

    if (additionalData.currentLocation) {
      this.currentLocation = additionalData.currentLocation;
    }
  }

  assignShipper(shipperId, shipperName, shipperPhone) {
    this.shipperId = shipperId || '';
    this.shipperName = shipperName || '';
    this.shipperPhone = shipperPhone || '';
    this.status = 'assigned';
    this.updatedAt = new Date().toISOString();
  }

  toJSON() {
    return {
      id: this.id || '',
      orderId: this.orderId || '',
      shipperId: this.shipperId || null,
      shipperName: this.shipperName || null,
      shipperPhone: this.shipperPhone || null,
      status: this.status || 'pending',
      pickupAddress: this.pickupAddress || {},
      deliveryAddress: this.deliveryAddress || {},
      currentLocation: this.currentLocation || null,
      estimatedDeliveryTime: this.estimatedDeliveryTime || null,
      actualDeliveryTime: this.actualDeliveryTime || null,
      notes: this.notes || '',
      failureReason: this.failureReason || null,
      createdAt: this.createdAt || new Date().toISOString(),
      updatedAt: this.updatedAt || new Date().toISOString(),
    };
  }

  static fromBigtableRow(row, rowData) {
    // Use parseRowData helper to ensure proper UTF-8 decoding
    const parsedData = parseRowData(rowData);
    
    return new Delivery({
      id: row.id || '',
      orderId: decodeEscapedUTF8(parsedData.orderId) || '',
      shipperId: parsedData.shipperId || null,
      shipperName: decodeEscapedUTF8(parsedData.shipperName) || null,
      shipperPhone: decodeEscapedUTF8(parsedData.shipperPhone) || null,
      status: parsedData.status || 'pending',
      pickupAddress: parsedData.pickupAddress ? JSON.parse(parsedData.pickupAddress || '{}') : {},
      deliveryAddress: parsedData.deliveryAddress ? JSON.parse(parsedData.deliveryAddress || '{}') : {},
      currentLocation: parsedData.currentLocation ? JSON.parse(parsedData.currentLocation || '{}') : null,
      estimatedDeliveryTime: parsedData.estimatedDeliveryTime || null,
      actualDeliveryTime: parsedData.actualDeliveryTime || null,
      notes: decodeEscapedUTF8(parsedData.notes) || '',
      failureReason: decodeEscapedUTF8(parsedData.failureReason) || null,
      createdAt: parsedData.createdAt || new Date().toISOString(),
      updatedAt: parsedData.updatedAt || new Date().toISOString(),
    });
  }
}

module.exports = Delivery;
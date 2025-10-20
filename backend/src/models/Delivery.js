const { v4: uuidv4 } = require('uuid');

class Delivery {
  constructor(data) {
    this.id = data.id || `delivery#${uuidv4()}`;
    this.orderId = data.orderId;
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
    this.shipperId = shipperId;
    this.shipperName = shipperName;
    this.shipperPhone = shipperPhone;
    this.status = 'assigned';
    this.updatedAt = new Date().toISOString();
  }

  toJSON() {
    return {
      id: this.id,
      orderId: this.orderId,
      shipperId: this.shipperId,
      shipperName: this.shipperName,
      shipperPhone: this.shipperPhone,
      status: this.status,
      pickupAddress: this.pickupAddress,
      deliveryAddress: this.deliveryAddress,
      currentLocation: this.currentLocation,
      estimatedDeliveryTime: this.estimatedDeliveryTime,
      actualDeliveryTime: this.actualDeliveryTime,
      notes: this.notes,
      failureReason: this.failureReason,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }

  static fromBigtableRow(row, rowData) {
    return new Delivery({
      id: row.id,
      orderId: rowData.orderId,
      shipperId: rowData.shipperId,
      shipperName: rowData.shipperName,
      shipperPhone: rowData.shipperPhone,
      status: rowData.status,
      pickupAddress: rowData.pickupAddress ? JSON.parse(rowData.pickupAddress) : {},
      deliveryAddress: rowData.deliveryAddress ? JSON.parse(rowData.deliveryAddress) : {},
      currentLocation: rowData.currentLocation ? JSON.parse(rowData.currentLocation) : null,
      estimatedDeliveryTime: rowData.estimatedDeliveryTime,
      actualDeliveryTime: rowData.actualDeliveryTime,
      notes: rowData.notes,
      failureReason: rowData.failureReason,
      createdAt: rowData.createdAt,
      updatedAt: rowData.updatedAt,
    });
  }
}

module.exports = Delivery;







const { v4: uuidv4 } = require('uuid');

class Order {
  constructor(data) {
    this.id = data.id || `order#${uuidv4()}`;
    this.userId = data.userId;
    this.storeId = data.storeId;
    this.items = data.items || [];
    this.subtotal = data.subtotal || 0;
    this.tax = data.tax || 0;
    this.deliveryFee = data.deliveryFee || 0;
    this.discount = data.discount || 0;
    this.total = data.total || 0;
    this.status = data.status || 'pending'; // pending, confirmed, preparing, delivering, completed, cancelled
    this.paymentMethod = data.paymentMethod || 'COD'; // COD, card, momo, zalopay
    this.paymentStatus = data.paymentStatus || 'pending'; // pending, paid, failed, refunded
    this.deliveryAddress = data.deliveryAddress || {};
    this.notes = data.notes || '';
    this.orderTime = data.orderTime || new Date().toISOString();
    this.confirmedTime = data.confirmedTime || null;
    this.completedTime = data.completedTime || null;
    this.cancelledTime = data.cancelledTime || null;
    this.cancelReason = data.cancelReason || null;
    this.promotionCode = data.promotionCode || null;
  }

  canBeCancelled() {
    return ['pending', 'confirmed'].includes(this.status);
  }

  toJSON() {
    return {
      id: this.id,
      userId: this.userId,
      storeId: this.storeId,
      items: this.items,
      subtotal: this.subtotal,
      tax: this.tax,
      deliveryFee: this.deliveryFee,
      discount: this.discount,
      total: this.total,
      status: this.status,
      paymentMethod: this.paymentMethod,
      paymentStatus: this.paymentStatus,
      deliveryAddress: this.deliveryAddress,
      notes: this.notes,
      orderTime: this.orderTime,
      confirmedTime: this.confirmedTime,
      completedTime: this.completedTime,
      cancelledTime: this.cancelledTime,
      cancelReason: this.cancelReason,
      promotionCode: this.promotionCode,
    };
  }

  static fromBigtableRow(row, rowData) {
    const items = [];
    
    // Parse items from Bigtable
    Object.keys(rowData).forEach(key => {
      if (key.startsWith('item_')) {
        items.push(JSON.parse(rowData[key]));
      }
    });

    return new Order({
      id: row.id,
      userId: rowData.userId,
      storeId: rowData.storeId,
      items,
      subtotal: parseFloat(rowData.subtotal) || 0,
      tax: parseFloat(rowData.tax) || 0,
      deliveryFee: parseFloat(rowData.deliveryFee) || 0,
      discount: parseFloat(rowData.discount) || 0,
      total: parseFloat(rowData.total) || 0,
      status: rowData.status,
      paymentMethod: rowData.paymentMethod,
      paymentStatus: rowData.paymentStatus,
      deliveryAddress: rowData.deliveryAddress ? JSON.parse(rowData.deliveryAddress) : {},
      notes: rowData.notes,
      orderTime: rowData.orderTime,
      confirmedTime: rowData.confirmedTime,
      completedTime: rowData.completedTime,
      cancelledTime: rowData.cancelledTime,
      cancelReason: rowData.cancelReason,
      promotionCode: rowData.promotionCode,
    });
  }

  // Generate row key with reversed timestamp for efficient recent-first queries
  static generateRowKey(orderId) {
    const timestamp = Date.now();
    const reversedTimestamp = 9999999999999 - timestamp;
    return `order#${reversedTimestamp}#${orderId}`;
  }
}

module.exports = Order;





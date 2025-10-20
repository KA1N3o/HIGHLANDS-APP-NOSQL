const { v4: uuidv4 } = require('uuid');
const { parseRowData, decodeEscapedUTF8 } = require('../utils/helpers');

class Order {
  constructor(data) {
    this.id = data.id || `order#${uuidv4()}`;
    this.userId = data.userId || '';
    this.storeId = data.storeId || '';
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
      id: this.id || '',
      userId: this.userId || '',
      storeId: this.storeId || '',
      items: this.items || [],
      subtotal: this.subtotal || 0,
      tax: this.tax || 0,
      deliveryFee: this.deliveryFee || 0,
      discount: this.discount || 0,
      total: this.total || 0,
      status: this.status || 'pending',
      paymentMethod: this.paymentMethod || 'COD',
      paymentStatus: this.paymentStatus || 'pending',
      deliveryAddress: this.deliveryAddress || {},
      notes: this.notes || '',
      orderTime: this.orderTime || new Date().toISOString(),
      confirmedTime: this.confirmedTime || null,
      completedTime: this.completedTime || null,
      cancelledTime: this.cancelledTime || null,
      cancelReason: this.cancelReason || null,
      promotionCode: this.promotionCode || null,
    };
  }

  static fromBigtableRow(row, rowData) {
    // Use parseRowData helper to ensure proper UTF-8 decoding
    const parsedData = parseRowData(rowData);
    
    const items = [];
    
    // Parse items from Bigtable
    Object.keys(parsedData).forEach(key => {
      if (key.startsWith('item_')) {
        try {
          // Properly decode UTF-8 for item data
          let itemValue = parsedData[key];
          itemValue = decodeEscapedUTF8(itemValue);
          items.push(JSON.parse(itemValue || '{}'));
        } catch (error) {
          console.error(`Error parsing item ${key}:`, error);
        }
      }
    });

    return new Order({
      id: row.id || '',
      userId: decodeEscapedUTF8(parsedData.userId) || '',
      storeId: decodeEscapedUTF8(parsedData.storeId) || '',
      items: items,
      subtotal: parseFloat(parsedData.subtotal) || 0,
      tax: parseFloat(parsedData.tax) || 0,
      deliveryFee: parseFloat(parsedData.deliveryFee) || 0,
      discount: parseFloat(parsedData.discount) || 0,
      total: parseFloat(parsedData.total) || 0,
      status: parsedData.status || 'pending',
      paymentMethod: parsedData.paymentMethod || 'COD',
      paymentStatus: parsedData.paymentStatus || 'pending',
      deliveryAddress: parsedData.deliveryAddress ? JSON.parse(parsedData.deliveryAddress || '{}') : {},
      notes: decodeEscapedUTF8(parsedData.notes) || '',
      orderTime: parsedData.orderTime || new Date().toISOString(),
      confirmedTime: parsedData.confirmedTime || null,
      completedTime: parsedData.completedTime || null,
      cancelledTime: parsedData.cancelledTime || null,
      cancelReason: parsedData.cancelReason || null,
      promotionCode: parsedData.promotionCode || null,
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
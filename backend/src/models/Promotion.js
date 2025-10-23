const { v4: uuidv4 } = require('uuid');
const { decodeEscapedUTF8 } = require('../utils/helpers');

class Promotion {
  constructor(data) {
    this.id = data.id || `promo#${uuidv4()}`;
    this.code = data.code || ''; // Mã khuyến mãi
    this.name = data.name || '';
    this.description = data.description || '';
    this.type = data.type || 'percentage'; // percentage, fixed_amount, free_shipping
    this.value = data.value || 0; // Giá trị giảm giá (% hoặc số tiền)
    this.minOrderValue = data.minOrderValue || 0; // Giá trị đơn hàng tối thiểu
    this.maxDiscount = data.maxDiscount || null; // Giảm giá tối đa (cho type percentage)
    this.usageLimit = data.usageLimit || null; // Số lần sử dụng tối đa (null = unlimited)
    this.usageCount = data.usageCount || 0; // Số lần đã sử dụng
    this.startDate = data.startDate || new Date().toISOString();
    this.endDate = data.endDate || new Date().toISOString();
    this.isActive = data.isActive !== undefined ? data.isActive : true;
    this.createdAt = data.createdAt || new Date().toISOString();
    this.updatedAt = data.updatedAt || new Date().toISOString();
  }

  isValid() {
    if (!this.isActive) return false;
    
    // Use UTC for comparison to avoid timezone issues
    const now = new Date();
    
    // Parse dates - they might be in local time or UTC
    let startDate = new Date(this.startDate);
    let endDate = new Date(this.endDate);
    
    // If dates are in local time (no Z), they need to be adjusted
    // Check if startDate string contains 'Z' or timezone offset
    const startDateStr = this.startDate.toString();
    const endDateStr = this.endDate.toString();
    
    // If dates don't have timezone info, treat them as UTC
    if (!startDateStr.includes('Z') && !startDateStr.includes('+') && !startDateStr.includes('-', 10)) {
      // Add Z to make it UTC
      startDate = new Date(startDateStr + 'Z');
    }
    
    if (!endDateStr.includes('Z') && !endDateStr.includes('+') && !endDateStr.includes('-', 10)) {
      endDate = new Date(endDateStr + 'Z');
    }

    if (now < startDate || now > endDate) return false;
    
    if (this.usageLimit && this.usageCount >= this.usageLimit) return false;

    return true;
  }

  calculateDiscount(orderValue) {
    if (!this.isValid()) return 0;
    if (orderValue < this.minOrderValue) return 0;

    let discount = 0;

    if (this.type === 'percentage') {
      discount = (orderValue * this.value) / 100;
      if (this.maxDiscount) {
        discount = Math.min(discount, this.maxDiscount);
      }
    } else if (this.type === 'fixed_amount') {
      discount = this.value;
    } else if (this.type === 'free_shipping') {
      // For free shipping, return a nominal value (shipping cost)
      // This is handled separately in the checkout process
      discount = this.value || 0; // Can be 0, but we'll handle it specially
    }

    return Math.min(discount, orderValue);
  }

  incrementUsage() {
    this.usageCount += 1;
    this.updatedAt = new Date().toISOString();
  }

  toJSON() {
    return {
      id: this.id || '',
      code: this.code || '',
      name: this.name || '',
      description: this.description || '',
      type: this.type || 'percentage',
      value: this.value || 0,
      minOrderValue: this.minOrderValue || 0,
      maxDiscount: this.maxDiscount || null,
      usageLimit: this.usageLimit || null,
      usageCount: this.usageCount || 0,
      startDate: this.startDate || new Date().toISOString(),
      endDate: this.endDate || new Date().toISOString(),
      isActive: this.isActive || false,
      createdAt: this.createdAt || new Date().toISOString(),
      updatedAt: this.updatedAt || new Date().toISOString(),
    };
  }

  static fromBigtableRow(row, rowData) {
    // rowData is already parsed by promotionService, no need to parse again
    
    return new Promotion({
      id: row.id || '',
      code: decodeEscapedUTF8(rowData.code) || '',
      name: decodeEscapedUTF8(rowData.name) || '',
      description: decodeEscapedUTF8(rowData.description) || '',
      type: rowData.type || 'percentage',
      value: parseFloat(rowData.value) || 0,
      minOrderValue: parseFloat(rowData.minOrderValue) || 0,
      maxDiscount: rowData.maxDiscount ? parseFloat(rowData.maxDiscount) : null,
      usageLimit: rowData.usageLimit ? parseInt(rowData.usageLimit) : null,
      usageCount: parseInt(rowData.usageCount) || 0,
      startDate: rowData.startDate || new Date().toISOString(),
      endDate: rowData.endDate || new Date().toISOString(),
      isActive: (rowData.isActive === 'true') || (rowData.isActive === true),
      createdAt: rowData.createdAt || new Date().toISOString(),
      updatedAt: rowData.updatedAt || new Date().toISOString(),
    });
  }
}

module.exports = Promotion;


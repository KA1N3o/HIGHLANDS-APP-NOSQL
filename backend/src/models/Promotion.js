const { v4: uuidv4 } = require('uuid');
const { parseRowData, decodeEscapedUTF8 } = require('../utils/helpers');

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
    
    const now = new Date();
    const startDate = new Date(this.startDate);
    const endDate = new Date(this.endDate);

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
    // Use parseRowData helper to ensure proper UTF-8 decoding
    const parsedData = parseRowData(rowData);
    
    return new Promotion({
      id: row.id || '',
      code: decodeEscapedUTF8(parsedData.code) || '',
      name: decodeEscapedUTF8(parsedData.name) || '',
      description: decodeEscapedUTF8(parsedData.description) || '',
      type: parsedData.type || 'percentage',
      value: parseFloat(parsedData.value) || 0,
      minOrderValue: parseFloat(parsedData.minOrderValue) || 0,
      maxDiscount: parsedData.maxDiscount ? parseFloat(parsedData.maxDiscount) : null,
      usageLimit: parsedData.usageLimit ? parseInt(parsedData.usageLimit) : null,
      usageCount: parseInt(parsedData.usageCount) || 0,
      startDate: parsedData.startDate || new Date().toISOString(),
      endDate: parsedData.endDate || new Date().toISOString(),
      isActive: (parsedData.isActive === 'true') || (parsedData.isActive === true),
      createdAt: parsedData.createdAt || new Date().toISOString(),
      updatedAt: parsedData.updatedAt || new Date().toISOString(),
    });
  }
}

module.exports = Promotion;


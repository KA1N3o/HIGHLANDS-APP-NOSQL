const { v4: uuidv4 } = require('uuid');

class Promotion {
  constructor(data) {
    this.id = data.id || `promo#${uuidv4()}`;
    this.code = data.code; // Mã khuyến mãi
    this.name = data.name;
    this.description = data.description || '';
    this.type = data.type || 'percentage'; // percentage, fixed_amount, free_shipping
    this.value = data.value; // Giá trị giảm giá (% hoặc số tiền)
    this.minOrderValue = data.minOrderValue || 0; // Giá trị đơn hàng tối thiểu
    this.maxDiscount = data.maxDiscount || null; // Giảm giá tối đa (cho type percentage)
    this.usageLimit = data.usageLimit || null; // Số lần sử dụng tối đa (null = unlimited)
    this.usageCount = data.usageCount || 0; // Số lần đã sử dụng
    this.startDate = data.startDate;
    this.endDate = data.endDate;
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
      id: this.id,
      code: this.code,
      name: this.name,
      description: this.description,
      type: this.type,
      value: this.value,
      minOrderValue: this.minOrderValue,
      maxDiscount: this.maxDiscount,
      usageLimit: this.usageLimit,
      usageCount: this.usageCount,
      startDate: this.startDate,
      endDate: this.endDate,
      isActive: this.isActive,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }

  static fromBigtableRow(row, rowData) {
    return new Promotion({
      id: row.id,
      code: rowData.code,
      name: rowData.name,
      description: rowData.description,
      type: rowData.type,
      value: parseFloat(rowData.value),
      minOrderValue: parseFloat(rowData.minOrderValue) || 0,
      maxDiscount: rowData.maxDiscount ? parseFloat(rowData.maxDiscount) : null,
      usageLimit: rowData.usageLimit ? parseInt(rowData.usageLimit) : null,
      usageCount: parseInt(rowData.usageCount) || 0,
      startDate: rowData.startDate,
      endDate: rowData.endDate,
      isActive: rowData.isActive === 'true',
      createdAt: rowData.createdAt,
      updatedAt: rowData.updatedAt,
    });
  }
}

module.exports = Promotion;







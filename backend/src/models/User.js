const { v4: uuidv4 } = require('uuid');
const { parseRowData, decodeEscapedUTF8 } = require('../utils/helpers');

class User {
  constructor(data) {
    this.id = data.id || `user#${uuidv4()}`;
    this.email = data.email || '';
    this.name = data.name || '';
    this.phone = data.phone || '';
    this.photoUrl = data.photoUrl || null;
    this.role = data.role || 'customer'; // customer, staff, admin, shipper
    this.createdAt = data.createdAt || new Date().toISOString();
    this.addresses = data.addresses || [];
    this.defaultAddressIndex = data.defaultAddressIndex || 0;
  }

  toJSON() {
    return {
      id: this.id || '',
      email: this.email || '',
      name: this.name || '',
      phone: this.phone || '',
      photoUrl: this.photoUrl || null,
      role: this.role || 'customer',
      createdAt: this.createdAt || new Date().toISOString(),
      addresses: this.addresses || [],
      defaultAddressIndex: this.defaultAddressIndex || 0,
    };
  }

  static fromBigtableRow(row, rowData) {
    // Use parseRowData helper to ensure proper UTF-8 decoding
    const parsedData = parseRowData(rowData);
    
    return new User({
      id: row.id || '',
      email: decodeEscapedUTF8(parsedData.email) || '',
      name: decodeEscapedUTF8(parsedData.name) || '',
      phone: decodeEscapedUTF8(parsedData.phone) || '',
      photoUrl: parsedData.photoUrl || null,
      role: parsedData.role || 'customer',
      createdAt: parsedData.createdAt || new Date().toISOString(),
      addresses: parsedData.addresses ? JSON.parse(parsedData.addresses || '[]') : [],
      defaultAddressIndex: parsedData.defaultAddressIndex ? parseInt(parsedData.defaultAddressIndex) : 0,
    });
  }
}

module.exports = User;
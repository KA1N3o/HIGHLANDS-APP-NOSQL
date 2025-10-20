const { v4: uuidv4 } = require('uuid');

class User {
  constructor(data) {
    this.id = data.id || `user#${uuidv4()}`;
    this.email = data.email;
    this.name = data.name;
    this.phone = data.phone;
    this.photoUrl = data.photoUrl || null;
    this.role = data.role || 'customer'; // customer, staff, admin, shipper
    this.createdAt = data.createdAt || new Date().toISOString();
    this.addresses = data.addresses || [];
    this.defaultAddressIndex = data.defaultAddressIndex || 0;
  }

  toJSON() {
    return {
      id: this.id,
      email: this.email,
      name: this.name,
      phone: this.phone,
      photoUrl: this.photoUrl,
      role: this.role,
      createdAt: this.createdAt,
      addresses: this.addresses,
      defaultAddressIndex: this.defaultAddressIndex,
    };
  }

  static fromBigtableRow(row, rowData) {
    return new User({
      id: row.id,
      email: rowData.email,
      name: rowData.name,
      phone: rowData.phone,
      photoUrl: rowData.photoUrl,
      role: rowData.role,
      createdAt: rowData.createdAt,
      addresses: rowData.addresses ? JSON.parse(rowData.addresses) : [],
      defaultAddressIndex: rowData.defaultAddressIndex ? parseInt(rowData.defaultAddressIndex) : 0,
    });
  }
}

module.exports = User;




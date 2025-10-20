const { v4: uuidv4 } = require('uuid');

class Product {
  constructor(data) {
    this.id = data.id || `product#${uuidv4()}`;
    this.name = data.name;
    this.description = data.description || '';
    this.price = data.price;
    this.imageUrl = data.imageUrl || null;
    this.category = data.category; // coffee, tea, smoothie, food, pastry
    this.isAvailable = data.isAvailable !== undefined ? data.isAvailable : true;
    this.preparationTime = data.preparationTime || 10; // minutes
    this.sizes = data.sizes || ['Medium', 'Large'];
    this.options = data.options || []; // [{ name: 'Đường', choices: ['Ít', 'Vừa', 'Nhiều'] }]
    this.createdAt = data.createdAt || new Date().toISOString();
    this.updatedAt = data.updatedAt || new Date().toISOString();
  }

  toJSON() {
    return {
      id: this.id,
      name: this.name,
      description: this.description,
      price: this.price,
      imageUrl: this.imageUrl,
      category: this.category,
      isAvailable: this.isAvailable,
      preparationTime: this.preparationTime,
      sizes: this.sizes,
      options: this.options,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }

  static fromBigtableRow(row, rowData) {
    return new Product({
      id: row.id,
      name: rowData.name,
      description: rowData.description,
      price: parseFloat(rowData.price),
      imageUrl: rowData.imageUrl,
      category: rowData.category,
      isAvailable: rowData.isAvailable === 'true',
      preparationTime: parseInt(rowData.preparationTime) || 10,
      sizes: rowData.sizes ? JSON.parse(rowData.sizes) : [],
      options: rowData.options ? JSON.parse(rowData.options) : [],
      createdAt: rowData.createdAt,
      updatedAt: rowData.updatedAt,
    });
  }
}

module.exports = Product;





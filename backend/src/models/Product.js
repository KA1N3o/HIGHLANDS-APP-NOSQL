const { v4: uuidv4 } = require('uuid');
const { parseRowData, decodeEscapedUTF8 } = require('../utils/helpers');

class Product {
  constructor(data) {
    this.id = data.id || `product#${uuidv4()}`;
    this.name = data.name || '';
    this.description = data.description || '';
    this.price = data.price || 0;
    this.imageUrl = data.imageUrl || null;
    this.category = data.category || 'other'; // coffee, tea, smoothie, food, pastry, merchandise
    this.isAvailable = data.isAvailable !== undefined ? data.isAvailable : true;
    this.preparationTime = data.preparationTime || 10; // minutes
    this.rating = data.rating !== undefined ? parseFloat(data.rating) : 4.5; // 0-5 stars
    this.reviewCount = data.reviewCount !== undefined ? parseInt(data.reviewCount) : 0;
    this.sizes = data.sizes || ['Medium', 'Large'];
    this.options = data.options || []; // [{ name: 'Đường', choices: ['Ít', 'Vừa', 'Nhiều'] }]
    this.availableToppings = data.availableToppings || []; // [{ id: 'topping1', name: 'Trân châu', price: 10000 }]
    this.createdAt = data.createdAt || new Date().toISOString();
    this.updatedAt = data.updatedAt || new Date().toISOString();
  }

  toJSON() {
    return {
      id: this.id || '',
      name: this.name || '',
      description: this.description || '',
      price: this.price || 0,
      imageUrl: this.imageUrl || null,
      category: this.category || 'other',
      isAvailable: this.isAvailable || false,
      preparationTime: this.preparationTime || 10,
      rating: this.rating || 4.5,
      reviewCount: this.reviewCount || 0,
      sizes: this.sizes || [],
      options: this.options || [],
      availableToppings: this.availableToppings || [],
      createdAt: this.createdAt || new Date().toISOString(),
      updatedAt: this.updatedAt || new Date().toISOString(),
    };
  }

  static fromBigtableRow(row, rowData) {
    // Use parseRowData helper to ensure proper UTF-8 decoding
    const parsedData = parseRowData(rowData);
    
    return new Product({
      id: row.id || '',
      name: decodeEscapedUTF8(parsedData.name) || '',
      description: decodeEscapedUTF8(parsedData.description) || '',
      price: parseFloat(parsedData.price) || 0,
      imageUrl: parsedData.imageUrl || null,
      category: parsedData.category || 'other',
      isAvailable: (parsedData.isAvailable === 'true') || (parsedData.isAvailable === true),
      preparationTime: parseInt(parsedData.preparationTime) || 10,
      rating: parsedData.rating ? parseFloat(parsedData.rating) : 4.5,
      reviewCount: parsedData.reviewCount ? parseInt(parsedData.reviewCount) : 0,
      sizes: parsedData.sizes ? JSON.parse(parsedData.sizes || '[]') : [],
      options: parsedData.options ? JSON.parse(parsedData.options || '[]') : [],
      availableToppings: parsedData.availableToppings ? JSON.parse(parsedData.availableToppings || '[]') : [],
      createdAt: parsedData.createdAt || new Date().toISOString(),
      updatedAt: parsedData.updatedAt || new Date().toISOString(),
    });
  }
}

module.exports = Product;
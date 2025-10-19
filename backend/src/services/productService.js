const { tables } = require('../config/bigtable');
const { parseRowData } = require('../utils/helpers');

class ProductService {
  /**
   * Get all products
   */
  async getAllProducts() {
    const productsTable = tables.products;
    
    const [rows] = await productsTable.getRows();

    return rows.map((row) => {
      const data = parseRowData(row);
      
      // Parse JSON fields
      let sizes = [];
      let options = [];
      
      try {
        sizes = JSON.parse(data.sizes);
      } catch {
        sizes = data.sizes || [];
      }
      
      try {
        options = JSON.parse(data.optionsData || '[]');
      } catch {
        options = [];
      }

      return {
        id: row.id,
        name: data.name,
        description: data.description,
        price: parseFloat(data.price),
        imageUrl: data.imageUrl,
        category: data.category,
        isAvailable: data.isAvailable === 'true',
        preparationTime: parseInt(data.preparationTime),
        sizes,
        options,
      };
    });
  }

  /**
   * Get product by ID
   */
  async getProductById(productId) {
    const productsTable = tables.products;
    const row = productsTable.row(productId);

    const [data] = await row.get();
    
    if (!data) {
      throw new Error('Product not found');
    }

    const productData = parseRowData(data);
    
    // Parse JSON fields
    let sizes = [];
    let options = [];
    
    try {
      sizes = JSON.parse(productData.sizes);
    } catch {
      sizes = productData.sizes || [];
    }
    
    try {
      options = JSON.parse(productData.optionsData || '[]');
    } catch {
      options = [];
    }

    return {
      id: productId,
      name: productData.name,
      description: productData.description,
      price: parseFloat(productData.price),
      imageUrl: productData.imageUrl,
      category: productData.category,
      isAvailable: productData.isAvailable === 'true',
      preparationTime: parseInt(productData.preparationTime),
      sizes,
      options,
    };
  }

  /**
   * Get products by category
   */
  async getProductsByCategory(category) {
    const allProducts = await this.getAllProducts();
    return allProducts.filter((product) => product.category === category);
  }
}

module.exports = new ProductService();


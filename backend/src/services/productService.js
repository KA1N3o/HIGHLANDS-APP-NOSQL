const { tables } = require('../config/bigtable');
const { parseRowData, createMutations } = require('../utils/helpers');
const Product = require('../models/Product');

class ProductService {
  /**
   * Get all products
   */
  async getAllProducts(availableOnly = false) {
    const productsTable = tables.products;
    
    const [rows] = await productsTable.getRows();

    let products = rows.map((row) => {
      const data = parseRowData(row);
      
      // Debug: Check what parseRowData returned
      console.log('DEBUG: data.sizes type:', typeof data.sizes);
      console.log('DEBUG: data.sizes value:', data.sizes);
      
      // Parse JSON fields (parseRowData already parsed JSON, so check if it's already parsed)
      let sizes = [];
      let options = [];
      
      if (Array.isArray(data.sizes)) {
        sizes = data.sizes;
      } else if (typeof data.sizes === 'string') {
        try {
          sizes = JSON.parse(data.sizes);
        } catch {
          sizes = [];
        }
      } else {
        sizes = [];
      }
      
      if (Array.isArray(data.options)) {
        options = data.options;
      } else if (typeof data.options === 'string') {
        try {
          options = JSON.parse(data.options || '[]');
        } catch {
          options = [];
        }
      } else {
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
        preparationTime: parseInt(data.preparationTime) || 10,
        sizes,
        options,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      };
    });

    if (availableOnly) {
      products = products.filter(p => p.isAvailable);
    }

    return products;
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
    
    // Parse JSON fields (parseRowData already parsed JSON, so check if it's already parsed)
    let sizes = [];
    let options = [];
    
    if (Array.isArray(productData.sizes)) {
      sizes = productData.sizes;
    } else if (typeof productData.sizes === 'string') {
      try {
        sizes = JSON.parse(productData.sizes);
      } catch {
        sizes = [];
      }
    } else {
      sizes = [];
    }
    
    if (Array.isArray(productData.options)) {
      options = productData.options;
    } else if (typeof productData.options === 'string') {
      try {
        options = JSON.parse(productData.options || '[]');
      } catch {
        options = [];
      }
    } else {
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
      preparationTime: parseInt(productData.preparationTime) || 10,
      sizes,
      options,
      createdAt: productData.createdAt,
      updatedAt: productData.updatedAt,
    };
  }

  /**
   * Get products by category
   */
  async getProductsByCategory(category, availableOnly = false) {
    const allProducts = await this.getAllProducts(availableOnly);
    return allProducts.filter((product) => product.category === category);
  }

  /**
   * Search products by name or keyword
   */
  async searchProducts(keyword, availableOnly = false) {
    const allProducts = await this.getAllProducts(availableOnly);
    const lowerKeyword = keyword.toLowerCase();
    
    return allProducts.filter(product => 
      product.name.toLowerCase().includes(lowerKeyword) ||
      product.description.toLowerCase().includes(lowerKeyword)
    );
  }

  /**
   * Create new product (admin only)
   */
  async createProduct(productData) {
    const product = new Product(productData);
    await this.saveProduct(product);
    return product.toJSON();
  }

  /**
   * Update product (admin only)
   */
  async updateProduct(productId, updates) {
    const product = await this.getProductById(productId);

    // Update allowed fields
    const allowedFields = [
      'name', 'description', 'price', 'imageUrl', 'category',
      'isAvailable', 'preparationTime', 'sizes', 'options'
    ];

    const updateData = {};
    allowedFields.forEach(field => {
      if (updates[field] !== undefined) {
        updateData[field] = updates[field];
      }
    });

    updateData.updatedAt = new Date().toISOString();

    const productsTable = tables.products;
    const row = productsTable.row(productId);

    // Prepare mutations
    const mutations = {
      name: updateData.name || product.name,
      description: updateData.description !== undefined ? updateData.description : product.description,
      price: updateData.price !== undefined ? updateData.price.toString() : product.price.toString(),
      imageUrl: updateData.imageUrl !== undefined ? updateData.imageUrl : product.imageUrl,
      category: updateData.category || product.category,
      isAvailable: updateData.isAvailable !== undefined ? updateData.isAvailable.toString() : product.isAvailable.toString(),
      preparationTime: updateData.preparationTime !== undefined ? updateData.preparationTime.toString() : product.preparationTime.toString(),
      sizes: JSON.stringify(updateData.sizes || product.sizes),
      options: JSON.stringify(updateData.options || product.options),
      updatedAt: updateData.updatedAt,
    };

    const infoMutations = createMutations('info', mutations);
    await row.save(infoMutations);

    return this.getProductById(productId);
  }

  /**
   * Delete product (admin only)
   */
  async deleteProduct(productId) {
    const productsTable = tables.products;
    const row = productsTable.row(productId);
    
    // Check if exists
    const [data] = await row.get();
    if (!data) {
      throw new Error('Product not found');
    }

    await row.delete();
  }

  /**
   * Save product to Bigtable
   */
  async saveProduct(product) {
    const productsTable = tables.products;
    const row = productsTable.row(product.id);

    const mutations = [
      {
        method: 'insert',
        data: {
          info: {
            name: product.name,
            description: product.description,
            price: product.price.toString(),
            imageUrl: product.imageUrl || '',
            category: product.category,
            isAvailable: product.isAvailable.toString(),
            preparationTime: product.preparationTime.toString(),
            createdAt: product.createdAt,
            updatedAt: product.updatedAt,
          },
        },
      },
      {
        method: 'insert',
        data: {
          options: {
            sizes: JSON.stringify(product.sizes),
            options: JSON.stringify(product.options),
          },
        },
      },
    ];

    await row.save(mutations);
  }
}

module.exports = new ProductService();


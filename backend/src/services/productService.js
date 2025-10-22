const { tables } = require('../config/bigtable');
const { parseRowData, createMutations } = require('../utils/helpers');
const Product = require('../models/Product');

class ProductService {
  constructor() {
    this._productCache = {};
  }

  /**
   * Get all products
   */
  async getAllProducts(availableOnly = false, limit = 100) {
    const startTime = Date.now();
    const productsTable = tables.products;
    
    // Use cache if available and fresh (10 minutes)
    const cacheKey = `products_${availableOnly}`;
    if (this._productCache && this._productCache[cacheKey]) {
      const cached = this._productCache[cacheKey];
      if (Date.now() - cached.timestamp < 10 * 60 * 1000) {
        console.log(`Products: Returned ${cached.products.length} products from cache`);
        return cached.products;
      }
    }
    
    // Add limit to prevent full table scan
    const [rows] = await productsTable.getRows({ limit });
    console.log(`Products: Fetched ${rows.length} rows in ${Date.now() - startTime}ms`);

    let products = rows.map((row) => {
      const data = parseRowData(row.data || row);
      
      // Skip products without required fields
      if (!data.name) {
        console.warn(`Skipping product with ID ${row.id} due to missing name`);
        return null;
      }
      
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

      // Parse availableToppings
      let availableToppings = [];
      if (Array.isArray(data.availableToppings)) {
        availableToppings = data.availableToppings;
      } else if (typeof data.availableToppings === 'string') {
        try {
          availableToppings = JSON.parse(data.availableToppings || '[]');
        } catch {
          availableToppings = [];
        }
      } else {
        availableToppings = [];
      }

      const isAvailable = (data.isAvailable === true) || (String(data.isAvailable).toLowerCase() === 'true');

      return {
        id: row.id,
        name: data.name,
        description: data.description || '',
        price: parseFloat(data.price) || 0,
        imageUrl: data.imageUrl || '',
        category: data.category || 'other',
        isAvailable,
        preparationTime: parseInt(data.preparationTime) || 10,
        rating: data.rating ? parseFloat(data.rating) : 4.5,
        reviewCount: data.reviewCount ? parseInt(data.reviewCount) : 0,
        sizes,
        options,
        availableToppings,
        createdAt: data.createdAt || new Date().toISOString(),
        updatedAt: data.updatedAt || new Date().toISOString(),
      };
    }).filter(product => product !== null);

    if (availableOnly) {
      products = products.filter(p => p.isAvailable);
    }

    // Cache the results
    if (!this._productCache) {
      this._productCache = {};
    }
    this._productCache[cacheKey] = {
      products,
      timestamp: Date.now()
    };

    console.log(`Products: Total processing time ${Date.now() - startTime}ms, returning ${products.length} products`);
    return products;
  }

  /**
   * Get product by ID
   */
  async getProductById(productId) {
    console.log(`DEBUG: Getting product by ID: ${productId}`);
    const productsTable = tables.products;
    const row = productsTable.row(productId);

    const [data] = await row.get();
    
    if (!data) {
      console.log(`DEBUG: Product not found with ID: ${productId}`);
      // Try to list all products to debug
      const [allRows] = await productsTable.getRows({ limit: 10 });
      console.log(`DEBUG: First 10 product IDs in database:`, allRows.map(r => r.id));
      throw new Error('Product not found');
    }
    
    console.log(`DEBUG: Found product data for ${productId}`);

    const productData = parseRowData(data.data || data);
    
    // Debug: Log parsed data
    console.log(`DEBUG: Parsed product data for ${productId}:`, JSON.stringify(productData, null, 2));
    
    // Validate required fields
    if (!productData.name) {
      throw new Error(`Product with ID ${productId} has invalid data (missing name)`);
    }
    
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

    const isAvailable = (productData.isAvailable === true) || (String(productData.isAvailable).toLowerCase() === 'true');

    return {
      id: productId,
      name: productData.name,
      description: productData.description || '',
      price: parseFloat(productData.price) || 0,
      imageUrl: productData.imageUrl || '',
      category: productData.category || 'other',
      isAvailable,
      preparationTime: parseInt(productData.preparationTime) || 10,
      rating: productData.rating ? parseFloat(productData.rating) : 4.5,
      reviewCount: productData.reviewCount ? parseInt(productData.reviewCount) : 0,
      sizes,
      options,
      createdAt: productData.createdAt || new Date().toISOString(),
      updatedAt: productData.updatedAt || new Date().toISOString(),
    };
  }

  /**
   * Get products by category
   */
  async getProductsByCategory(category, availableOnly = false, limit = 100) {
    const allProducts = await this.getAllProducts(availableOnly, limit);
    return allProducts.filter((product) => product.category === category);
  }

  /**
   * Search products by name or keyword
   */
  async searchProducts(keyword, availableOnly = false, limit = 100) {
    const allProducts = await this.getAllProducts(availableOnly, limit);
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
    console.log(`DEBUG: Creating product with ID: ${product.id}`);
    await this.saveProduct(product);
    
    // Clear cache after creating
    this._productCache = {};
    
    return product.toJSON();
  }

  /**
   * Update product (admin only)
   */
  async updateProduct(productId, updates) {
    console.log(`DEBUG: Updating product with ID: ${productId}`);
    console.log(`DEBUG: Updates:`, JSON.stringify(updates, null, 2));
    
    // Clear cache before update
    this._productCache = {};
    
    const product = await this.getProductById(productId);
    console.log(`DEBUG: Found product:`, JSON.stringify(product, null, 2));

    // Update allowed fields
    const allowedFields = [
      'name', 'description', 'price', 'imageUrl', 'category',
      'isAvailable', 'preparationTime', 'sizes', 'options', 'availableToppings'
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
      availableToppings: JSON.stringify(updateData.availableToppings || product.availableToppings || []),
      updatedAt: updateData.updatedAt,
    };

    const infoMutations = createMutations('info', mutations);
    await row.save(infoMutations);

    // Clear cache after update
    this._productCache = {};
    
    console.log(`DEBUG: Product updated successfully`);
    return this.getProductById(productId);
  }

  /**
   * Delete product (admin only)
   */
  async deleteProduct(productId) {
    console.log(`DEBUG: Deleting product with ID: ${productId}`);
    const productsTable = tables.products;
    const row = productsTable.row(productId);
    
    // Check if exists
    const [data] = await row.get();
    if (!data) {
      console.log(`DEBUG: Product not found for deletion: ${productId}`);
      throw new Error('Product not found');
    }

    await row.delete();
    
    // Clear cache after deletion
    this._productCache = {};
    
    console.log(`DEBUG: Product deleted successfully`);
  }

  /**
   * Clear product cache
   */
  clearCache() {
    console.log('Clearing product cache');
    this._productCache = {};
  }

  /**
   * Save product to Bigtable
   */
  async saveProduct(product) {
    console.log(`DEBUG saveProduct: Saving product ${product.id}`);
    const productsTable = tables.products;
    const row = productsTable.row(product.id);

    // Use createMutations helper for proper format
    const infoMutations = createMutations('info', {
      name: product.name,
      description: product.description,
      price: product.price.toString(),
      imageUrl: product.imageUrl || '',
      category: product.category,
      isAvailable: product.isAvailable.toString(),
      preparationTime: product.preparationTime.toString(),
      rating: product.rating ? product.rating.toString() : '4.5',
      reviewCount: product.reviewCount ? product.reviewCount.toString() : '0',
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    });

    const optionsMutations = createMutations('options', {
      sizes: JSON.stringify(product.sizes),
      options: JSON.stringify(product.options),
      availableToppings: JSON.stringify(product.availableToppings || []),
    });

    // Combine all mutations
    const allMutations = [...infoMutations, ...optionsMutations];
    console.log(`DEBUG saveProduct: Saving ${allMutations.length} mutations`);
    
    await row.save(allMutations);
    console.log(`DEBUG saveProduct: Product ${product.id} saved successfully`);
  }
}

module.exports = new ProductService();


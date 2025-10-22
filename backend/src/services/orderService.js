const { tables } = require('../config/bigtable');
const {
  parseRowData,
  createMutations,
  generateId,
  getReversedTimestamp,
  calculateTax,
} = require('../utils/helpers');
const storeService = require('./storeService');
const productService = require('./productService');
const deliveryService = require('./deliveryService');
const userService = require('./userService');
const Order = require('../models/Order');

class OrderService {
  constructor() {
    // In-memory cache for stores with TTL
    this._storeCache = new Map();
    this._storeCacheTTL = 30 * 60 * 1000; // 30 minutes
    this._orderRowKeyCache = new Map();
    // In-memory cache for users
    this._userCache = new Map();
    this._userCacheTTL = 30 * 60 * 1000; // 30 minutes
    
    // Pre-load all stores on startup
    this._preloadStores();
  }

  /**
   * Pre-load all stores into cache on startup
   */
  async _preloadStores() {
    try {
      const stores = await storeService.getAllStores();
      stores.forEach(store => {
        this._storeCache.set(store.id, {
          data: store,
          timestamp: Date.now()
        });
      });
      console.log(`✓ Pre-loaded ${stores.length} stores into cache`);
    } catch (error) {
      console.error('Failed to pre-load stores:', error.message);
    }
  }

  /**
   * Get store with caching
   */
  async getStoreWithCache(storeId) {
    const cached = this._storeCache.get(storeId);
    if (cached && (Date.now() - cached.timestamp) < this._storeCacheTTL) {
      return cached.data;
    }

    try {
      const store = await storeService.getStoreById(storeId);
      this._storeCache.set(storeId, {
        data: store,
        timestamp: Date.now()
      });
      return store;
    } catch (error) {
      // Return fallback if store not found
      return {
        id: storeId,
        name: 'Unknown Store',
        address: 'Unknown Address',
        latitude: 0,
        longitude: 0,
        phone: '',
        imageUrl: '',
        isOpen: false,
        openTime: '08:00',
        closeTime: '22:00'
      };
    }
  }

  /**
   * Get user with caching
   */
  async getUserWithCache(userId) {
    const cached = this._userCache.get(userId);
    if (cached && (Date.now() - cached.timestamp) < this._userCacheTTL) {
      return cached.data;
    }

    try {
      const user = await userService.getUserById(userId);
      this._userCache.set(userId, {
        data: user,
        timestamp: Date.now()
      });
      return user;
    } catch (error) {
      // Return fallback if user not found
      return {
        id: userId,
        name: 'Unknown User',
        email: '',
        phone: ''
      };
    }
  }

  /**
   * Create a new order
   */
  async createOrder(userId, orderData) {
    const { storeId, items, paymentMethod, deliveryMethod, notes, deliveryAddress, promotionCode } = orderData;
    
    // Validate required fields
    if (!userId) {
      throw new Error('User ID is required');
    }
    
    if (!storeId) {
      throw new Error('Store ID is required');
    }
    
    // Validate store exists
    console.log(`DEBUG: Validating store with ID: ${storeId}`);
    let store;
    try {
      store = await storeService.getStoreById(storeId);
    } catch (error) {
      throw new Error(`Store with ID ${storeId} not found`);
    }

    // Validate items array
    if (!Array.isArray(items) || items.length === 0) {
      throw new Error('Order must contain at least one item');
    }

    // Calculate totals
    let subtotal = 0;
    const orderItems = [];

    for (const item of items) {
      // Validate productId exists
      if (!item.productId) {
        throw new Error('Product ID is required for all items');
      }
      
      let product;
      try {
        product = await productService.getProductById(item.productId);
      } catch (error) {
        throw new Error(`Product with ID ${item.productId} not found`);
      }
      
      if (!product) {
        throw new Error(`Product with ID ${item.productId} not found`);
      }
      
      // Check if product name exists
      if (!product.name) {
        throw new Error(`Product with ID ${item.productId} has invalid data (missing name)`);
      }
      
      if (!product.isAvailable) {
        throw new Error(`Product ${product.name} is not available`);
      }

      const itemTotal = (product.price || 0) * (item.quantity || 0);
      subtotal += itemTotal;

      orderItems.push({
        productId: item.productId || '',
        name: product.name || 'Unknown Product',
        price: product.price || 0,
        quantity: item.quantity || 0,
        size: item.size || 'Medium',
        options: item.options || [],
        total: itemTotal,
      });
    }

    const tax = calculateTax(subtotal);
    // Calculate delivery fee based on delivery method
    // pickup = 0, delivery = 15000
    const deliveryFee = deliveryMethod === 'pickup' ? 0 : 15000;
    let discount = 0;
    
    // Apply promotion if provided
    if (promotionCode) {
      const promotionService = require('./promotionService');
      try {
        const result = await promotionService.applyPromotion(promotionCode, subtotal);
        discount = result.discount;
        // Increment usage count
        await promotionService.incrementUsage(result.promotion.id);
      } catch (error) {
        // Invalid promotion, ignore
        console.log('Invalid promotion code:', error.message);
      }
    }
    
    const total = subtotal + tax + deliveryFee - discount;

    // Generate order ID with reversed timestamp
    const orderId = generateId('ord');
    const reversedTimestamp = getReversedTimestamp();
    const rowKey = `order#${reversedTimestamp}#${orderId}`;
    const orderTime = new Date().toISOString();

    // Create order mutations
    const ordersTable = tables.orders;
    const row = ordersTable.row(rowKey);

    const infoMutations = createMutations('info', {
      userId: userId || '',
      storeId: storeId || '',
      orderTime: orderTime || '',
      status: 'pending',
      deliveryMethod: deliveryMethod || 'pickup',
      notes: notes || '',
      deliveryAddress: JSON.stringify(deliveryAddress || {}),
      promotionCode: promotionCode || null,  // Store null instead of empty string
    });

    const paymentMutations = createMutations('payment', {
      method: paymentMethod || 'cash',
      status: 'pending',
      subtotal: String(subtotal),
      tax: String(tax),
      deliveryFee: String(deliveryFee),
      discount: String(discount),
      total: String(total),
    });

    // Store each item
    const itemsMutations = [];
    orderItems.forEach((item, index) => {
      itemsMutations.push({
        method: 'insert',
        data: {
          columnFamily: 'items',
          column: `item_${index}`,
          value: JSON.stringify(item),
        },
      });
    });

    await row.save([...infoMutations, ...paymentMutations, ...itemsMutations]);

    // Create index entry in orders_by_user table
    const ordersByUserTable = tables.ordersByUser;
    const indexRowKey = `${userId}#order#${reversedTimestamp}#${orderId}`;
    const indexRow = ordersByUserTable.row(indexRowKey);
    
    const refMutation = createMutations('ref', {
      orderRowKey: rowKey,
    });
    await indexRow.save(refMutation);

    // Create delivery record
    if (deliveryAddress) {
      await deliveryService.createDelivery({
        orderId: orderId || '',
        deliveryAddress: deliveryAddress || {},
        pickupAddress: {
          name: store.name || 'Unknown Store',
          address: store.address || 'Unknown Address',
          lat: store.latitude || 0,
          lng: store.longitude || 0,
        },
        status: 'pending',
      });
    }

    return {
      id: orderId || '',
      userId: userId || '',
      store: {
        id: store.id || storeId || '',
        name: store.name || 'Unknown Store',
        address: store.address || 'Unknown Address',
        latitude: store.latitude || 0,
        longitude: store.longitude || 0,
        phone: store.phone || '',
        imageUrl: store.imageUrl || '',
        isOpen: store.isOpen || false,
        openTime: store.openTime || '08:00',
        closeTime: store.closeTime || '22:00',
      },
      items: orderItems.map(item => ({
        product: {
          id: item.productId || '',
          name: item.name || 'Unknown Product',
          description: '', // Description not stored in order items
          price: (item.price || 0).toString(), // Convert to string for Flutter
          imageUrl: '', // Image URL not stored in order items
          category: 'coffee', // Category not stored in order items
          sizes: '[]', // Empty array as JSON string for Flutter
          options: '[]', // Empty array as JSON string for Flutter
          isAvailable: 'true', // String boolean for Flutter
          preparationTime: '10' // String number for Flutter
        },
        size: item.size || 'Medium',
        selectedOptions: {}, // Selected options not stored properly
        quantity: item.quantity || 0,
        notes: ''  // Ensure notes is always a string
      })),
      subtotal: subtotal,
      tax: tax,
      deliveryFee: deliveryFee,
      discount: discount,
      total: total,
      status: 'pending',
      paymentMethod: paymentMethod || 'cash',
      paymentStatus: 'pending',
      deliveryMethod: deliveryMethod || 'pickup',
      deliveryAddress: deliveryAddress || null,  // Return object or null, not JSON string
      orderTime: orderTime,
      notes: notes || '',
      promotionCode: promotionCode || null,  // Return null if not provided
    };
  }

  /**
   * Get orders for a specific user (OPTIMIZED - uses scan with filter instead of index)
   */
  async getUserOrders(userId, limit = 50) {
    try {
      const startTime = Date.now();
      // OPTIMIZATION: Scan all orders and filter by userId in memory
      // This is MUCH faster than querying index then fetching each order individually
      const allOrders = await this.getAllOrders(50); // Get up to 50 orders to filter from (reduced for performance)
      
      // Filter by userId
      const userOrders = allOrders.filter(order => order.userId === userId);
      
      // Apply limit
      const result = userOrders.slice(0, limit);
      
      const duration = Date.now() - startTime;
      console.log(`Orders: getUserOrders returned ${result.length} orders in ${duration}ms`);
      
      return result;
    } catch (error) {
      console.error(`Error getting user orders for ${userId}:`, error.message);
      // Return empty array if there's an error (e.g., no orders exist yet)
      return [];
    }
  }

  /**
   * Get order by ID
   */
  async getOrderById(orderId) {
    const ordersTable = tables.orders;

    // Check cache first
    let orderRowKey = this._orderRowKeyCache ? this._orderRowKeyCache.get(orderId) : null;
    
    // If not in cache, find by partial key match with limit
    if (!orderRowKey) {
      const [rows] = await ordersTable.getRows({ limit: 100 });
      
      console.log(`DEBUG: Searching for order with ID: ${orderId}`);
      console.log(`DEBUG: Found ${rows.length} total order rows`);
      
      const orderRow = rows.find((row) => {
        const matches = row.id.endsWith(`#${orderId}`);
        return matches;
      });

      if (!orderRow) {
        console.log(`DEBUG: Order not found for ID: ${orderId}`);
        throw new Error('Order not found');
      }

      orderRowKey = orderRow.id;
      
      // Cache the row key
      if (!this._orderRowKeyCache) {
        this._orderRowKeyCache = new Map();
      }
      this._orderRowKeyCache.set(orderId, orderRowKey);
      
      console.log(`DEBUG: Found order row:`, JSON.stringify(orderRow, null, 2));
      return this.parseOrderData(orderRow.id, orderRow);
    }
    
    // If in cache, get directly
    const row = ordersTable.row(orderRowKey);
    const [data] = await row.get();
    
    if (!data) {
      // Cache was stale, remove it
      this._orderRowKeyCache.delete(orderId);
      throw new Error('Order not found');
    }
    
    return this.parseOrderData(orderRowKey, data);
  }

  /**
   * Update order status (optimized - uses cache)
   */
  async updateOrderStatus(orderId, status) {
    // Normalize status value (trim whitespace and ensure lowercase)
    const normalizedStatus = String(status).trim().toLowerCase();
    console.log(`Updating order ${orderId} to status ${normalizedStatus}`);
    const ordersTable = tables.orders;

    // Use cache if available (from recent queries)
    if (!this._orderRowKeyCache) {
      this._orderRowKeyCache = new Map();
    }

    let orderRowKey = this._orderRowKeyCache.get(orderId);
    
    // If not in cache, find it (but use limit to reduce scan)
    if (!orderRowKey) {
      const [rows] = await ordersTable.getRows({ limit: 100 });
      const orderRow = rows.find((row) => row.id.endsWith(`#${orderId}`));

      if (!orderRow) {
        throw new Error('Order not found');
      }
      
      orderRowKey = orderRow.id;
      this._orderRowKeyCache.set(orderId, orderRowKey);
    }

    console.log(`Found orderRowKey: ${orderRowKey}`);
    const row = ordersTable.row(orderRowKey);
    
    const updateData = { status: normalizedStatus };
    
    // Add timestamps based on status
    if (normalizedStatus === 'confirmed') {
      updateData.confirmedTime = new Date().toISOString();
    } else if (normalizedStatus === 'completed') {
      updateData.completedTime = new Date().toISOString();
    } else if (normalizedStatus === 'cancelled') {
      updateData.cancelledTime = new Date().toISOString();
    }
    
    console.log(`Creating mutations with updateData:`, JSON.stringify(updateData));
    const mutations = createMutations('info', updateData);
    console.log(`Created mutations:`, JSON.stringify(mutations, null, 2));
    
    await row.save(mutations);
    console.log(`Mutations saved successfully for order ${orderId}`);

    // Add a small delay to ensure HBase commits the write
    await new Promise(resolve => setTimeout(resolve, 100));

    // Update delivery status if needed (async, don't wait)
    if (normalizedStatus === 'delivering' || normalizedStatus === 'completed') {
      this._updateDeliveryStatus(orderId, normalizedStatus).catch(err => 
        console.log('No delivery record found for order:', orderId)
      );
    }

    // Get current order data and update status field manually
    // (HBase may not have committed the write yet if we query immediately)
    const [currentRowData] = await row.get();
    if (!currentRowData) {
      throw new Error('Order not found after update');
    }
    
    console.log(`Retrieved row data after update:`, JSON.stringify(currentRowData, null, 2));
    
    const updatedOrder = await this.parseOrderData(orderRowKey, currentRowData);
    console.log(`Parsed order status from DB: ${updatedOrder.status}`);
    
    // Override with the new status we just set (since DB might not reflect it yet)
    updatedOrder.status = normalizedStatus;
    if (normalizedStatus === 'confirmed') {
      updatedOrder.confirmedTime = updateData.confirmedTime;
    } else if (normalizedStatus === 'completed') {
      updatedOrder.completedTime = updateData.completedTime;
    } else if (normalizedStatus === 'cancelled') {
      updatedOrder.cancelledTime = updateData.cancelledTime;
    }
    
    console.log(`Updated order ${orderId} - Status set to: ${updatedOrder.status}`);
    return updatedOrder;
  }

  async _updateDeliveryStatus(orderId, status) {
    const delivery = await deliveryService.getDeliveryByOrderId(orderId);
    if (status === 'delivering') {
      await deliveryService.updateDeliveryStatus(delivery.id, 'delivering');
    } else if (status === 'completed') {
      await deliveryService.updateDeliveryStatus(delivery.id, 'delivered', {
        actualDeliveryTime: new Date().toISOString(),
      });
    }
  }

  /**
   * Cancel order
   */
  async cancelOrder(orderId, userId, cancelReason) {
    const order = await this.getOrderById(orderId);

    // Check if user owns the order
    if (order.userId !== userId) {
      throw new Error('Unauthorized to cancel this order');
    }

    // Check if order can be cancelled
    if (!['pending', 'confirmed'].includes(order.status)) {
      throw new Error('Order cannot be cancelled at this stage');
    }

    const ordersTable = tables.orders;
    
    // Use cached row key or find with limit
    let orderRowKey = this._orderRowKeyCache ? this._orderRowKeyCache.get(orderId) : null;
    if (!orderRowKey) {
      const [rows] = await ordersTable.getRows({ limit: 100 });
      const orderRow = rows.find((row) => row.id.endsWith(`#${orderId}`));
      if (!orderRow) {
        throw new Error('Order not found');
      }
      orderRowKey = orderRow.id;
      if (!this._orderRowKeyCache) {
        this._orderRowKeyCache = new Map();
      }
      this._orderRowKeyCache.set(orderId, orderRowKey);
    }

    const row = ordersTable.row(orderRowKey);
    
    const mutations = createMutations('info', {
      status: 'cancelled',
      cancelledTime: new Date().toISOString(),
      cancelReason: cancelReason || 'Customer request',
    });

    await row.save(mutations);

    // Update delivery status
    try {
      const delivery = await deliveryService.getDeliveryByOrderId(orderId);
      await deliveryService.updateDeliveryStatus(delivery.id, 'failed', {
        failureReason: 'Order cancelled by customer',
      });
    } catch (error) {
      console.log('No delivery record found for order:', orderId);
    }

    return this.getOrderById(orderId);
  }

  /**
   * Update payment status
   */
  async updatePaymentStatus(orderId, paymentStatus) {
    const ordersTable = tables.orders;

    // Use cached row key or find with limit
    let orderRowKey = this._orderRowKeyCache ? this._orderRowKeyCache.get(orderId) : null;
    if (!orderRowKey) {
      const [rows] = await ordersTable.getRows({ limit: 100 });
      const orderRow = rows.find((row) => row.id.endsWith(`#${orderId}`));

      if (!orderRow) {
        throw new Error('Order not found');
      }
      
      orderRowKey = orderRow.id;
      if (!this._orderRowKeyCache) {
        this._orderRowKeyCache = new Map();
      }
      this._orderRowKeyCache.set(orderId, orderRowKey);
    }

    const row = ordersTable.row(orderRowKey);
    
    const mutations = createMutations('payment', { status: paymentStatus });
    await row.save(mutations);

    return this.getOrderById(orderId);
  }

  /**
   * Parse order data with store cache (optimized for bulk operations)
   */
  async parseOrderDataWithCache(rowKey, data, storeCache, userCache = null) {
    // Extract order ID from row key
    const orderId = rowKey.split('#').pop();

    // Parse items
    const items = [];
    for (const [key, value] of Object.entries(data)) {
      if (key.startsWith('item_')) {
        try {
          let itemData;
          
          // Check if value is already an object
          if (typeof value === 'object' && value !== null) {
            itemData = value;
          } else if (typeof value === 'string') {
            // Handle escaped characters properly
            let cleanValue = value;
            // Handle hex escape sequences
            cleanValue = cleanValue.replace(/\\x([0-9A-Fa-f]{2})/g, (match, hex) => {
              return String.fromCharCode(parseInt(hex, 16));
            });
            // Handle double escaped sequences
            cleanValue = cleanValue.replace(/\\\\x([0-9A-Fa-f]{2})/g, (match, hex) => {
              return String.fromCharCode(parseInt(hex, 16));
            });
            itemData = JSON.parse(cleanValue);
          } else {
            // Skip invalid value types
            continue;
          }
          
          // Convert to format expected by Flutter app
          const cartItem = {
            product: {
              id: itemData.productId || '',
              name: itemData.name || 'Unknown Product',
              description: '',
              price: (itemData.price || 0).toString(),
              imageUrl: '',
              category: 'coffee',
              sizes: '[]',
              options: '[]',
              isAvailable: 'true',
              preparationTime: '10'
            },
            size: itemData.size || 'Medium',
            selectedOptions: {},
            quantity: itemData.quantity || 0,
            notes: itemData.notes || ''
          };
          items.push(cartItem);
        } catch (error) {
          console.error(`Error parsing item ${key}:`, error.message);
          // Skip invalid items
        }
      }
    }

    // Get store from cache
    const store = storeCache.get(data.storeId) || {
      id: data.storeId || 'unknown',
      name: 'Unknown Store',
      address: 'Unknown Address',
      latitude: 0,
      longitude: 0,
      phone: '',
      imageUrl: '',
      isOpen: false,
      openTime: '08:00',
      closeTime: '22:00'
    };

    // Get user from cache if available
    const user = userCache ? userCache.get(data.userId) : null;

    const parsedOrder = {
      id: orderId || '',
      userId: data.userId || '',
      userName: user ? user.name : null,
      store: {
        id: store.id || data.storeId || 'unknown',
        name: store.name || 'Unknown Store',
        address: store.address || 'Unknown Address',
        latitude: store.latitude || 0,
        longitude: store.longitude || 0,
        phone: store.phone || '',
        imageUrl: store.imageUrl || '',
        isOpen: store.isOpen || false,
        openTime: store.openTime || '08:00',
        closeTime: store.closeTime || '22:00'
      },
      items: items,
      subtotal: parseFloat(data.subtotal) || 0,
      tax: parseFloat(data.tax) || 0,
      deliveryFee: parseFloat(data.deliveryFee) || 0,
      discount: parseFloat(data.discount) || 0,
      total: parseFloat(data.total) || 0,
      status: data.status || 'pending',
      paymentMethod: data.method || 'cash',
      paymentStatus: data.paymentStatus || data.status || 'pending',
      deliveryMethod: data.deliveryMethod || 'pickup',
      deliveryAddress: data.deliveryAddress ? (typeof data.deliveryAddress === 'string' ? JSON.parse(data.deliveryAddress) : data.deliveryAddress) : null,
      orderTime: data.orderTime || new Date().toISOString(),
      pickupTime: data.pickupTime || null,
      completedTime: data.completedTime || null,
      notes: data.notes || '',
      promotionCode: data.promotionCode || null,
    };
    
    return parsedOrder;
  }

  /**
   * Parse order data from Bigtable row
   */
  async parseOrderData(rowKey, rowData) {
    console.log(`DEBUG: Parsing order data for rowKey: ${rowKey}`);
    const data = parseRowData(rowData.data || rowData);
    console.log(`DEBUG: Parsed row data:`, JSON.stringify(data, null, 2));

    // Extract order ID from row key
    const orderId = rowKey.split('#').pop();

    // Parse items
    const items = [];
    for (const [key, value] of Object.entries(data)) {
      if (key.startsWith('item_')) {
        try {
          console.log(`DEBUG: Parsing item ${key}:`, typeof value, value);
          
          let itemData;
          
          // Check if value is already an object
          if (typeof value === 'object' && value !== null) {
            itemData = value;
          } else if (typeof value === 'string') {
            // Handle escaped characters properly
            let cleanValue = value;
            // Handle hex escape sequences
            cleanValue = cleanValue.replace(/\\x([0-9A-Fa-f]{2})/g, (match, hex) => {
              return String.fromCharCode(parseInt(hex, 16));
            });
            // Handle double escaped sequences
            cleanValue = cleanValue.replace(/\\\\x([0-9A-Fa-f]{2})/g, (match, hex) => {
              return String.fromCharCode(parseInt(hex, 16));
            });
            itemData = JSON.parse(cleanValue);
          } else {
            // Skip invalid value types
            console.error(`DEBUG: Unexpected value type for ${key}:`, typeof value);
            continue;
          }
          
          console.log(`DEBUG: Parsed item data:`, JSON.stringify(itemData, null, 2));
          // Convert to format expected by Flutter app
          const cartItem = {
            product: {
              id: itemData.productId || '',
              name: itemData.name || 'Unknown Product',
              description: '', // Description not stored in order items
              price: (itemData.price || 0).toString(), // Convert to string for Flutter
              imageUrl: '', // Image URL not stored in order items
              category: 'coffee', // Category not stored in order items
              sizes: '[]', // Empty array as JSON string for Flutter
              options: '[]', // Empty array as JSON string for Flutter
              isAvailable: 'true', // String boolean for Flutter
              preparationTime: '10' // String number for Flutter
            },
            size: itemData.size || 'Medium',
            selectedOptions: {}, // Selected options not stored properly
            quantity: itemData.quantity || 0,
            notes: itemData.notes || ''  // Ensure notes is always a string
          };
          console.log(`DEBUG: Converted cart item:`, JSON.stringify(cartItem, null, 2));
          items.push(cartItem);
        } catch (error) {
          console.error(`DEBUG: Error parsing item ${key}:`, error.message);
          // Skip invalid items
        }
      }
    }

    // Get store data
    let store = null;
    try {
      store = await storeService.getStoreById(data.storeId || '');
    } catch {
      store = { 
        id: data.storeId || 'unknown', 
        name: 'Unknown Store',
        address: 'Unknown Address',
        latitude: 0,
        longitude: 0,
        phone: '',
        imageUrl: '',
        isOpen: false,
        openTime: '08:00',
        closeTime: '22:00'
      };
    }

    return {
      id: orderId || '',
      userId: data.userId || '',
      store: {
        id: store.id || data.storeId || 'unknown',
        name: store.name || 'Unknown Store',
        address: store.address || 'Unknown Address',
        latitude: store.latitude || 0,
        longitude: store.longitude || 0,
        phone: store.phone || '',
        imageUrl: store.imageUrl || '',
        isOpen: store.isOpen || false,
        openTime: store.openTime || '08:00',
        closeTime: store.closeTime || '22:00'
      },
      items: items,
      subtotal: parseFloat(data.subtotal) || 0,
      tax: parseFloat(data.tax) || 0,
      deliveryFee: parseFloat(data.deliveryFee) || 0,  // Add deliveryFee field
      discount: parseFloat(data.discount) || 0,  // Add discount field
      total: parseFloat(data.total) || 0,
      status: data.status || 'pending',
      paymentMethod: data.method || 'cash',
      paymentStatus: data.paymentStatus || data.status || 'pending',
      deliveryMethod: data.deliveryMethod || 'pickup',
      deliveryAddress: data.deliveryAddress ? (typeof data.deliveryAddress === 'string' ? JSON.parse(data.deliveryAddress) : data.deliveryAddress) : null,  // Parse JSON string to object or return null
      orderTime: data.orderTime || new Date().toISOString(),
      pickupTime: data.pickupTime || null,  // Return null instead of empty string
      completedTime: data.completedTime || null,  // Return null instead of empty string
      notes: data.notes || '',  // Ensure notes is always a string
      promotionCode: data.promotionCode || null,  // Return null instead of empty string
    };
  }

  /**
   * Get all orders (admin only)
   */
  async getAllOrders(limit = 20) {
    try {
      const startTime = Date.now();
      const ordersTable = tables.orders;
      
      const [rows] = await ordersTable.getRows({ limit });
      console.log(`Orders: Fetched ${rows.length} rows in ${Date.now() - startTime}ms`);

      // If no rows found, return empty array
      if (!rows || rows.length === 0) {
        console.log('DEBUG: No orders found in database');
        return [];
      }

      // Initialize cache if needed
      if (!this._orderRowKeyCache) {
        this._orderRowKeyCache = new Map();
      }

      // Pre-fetch all unique stores and users to avoid N+1 queries
      const storeIds = new Set();
      const userIds = new Set();
      const rowData = [];
      
      for (const row of rows) {
        const orderId = row.id.split('#').pop();
        const data = parseRowData(row.data || row);
        
        if (data.storeId) {
          storeIds.add(data.storeId);
        }
        if (data.userId) {
          userIds.add(data.userId);
        }
        
        // Cache the rowKey for quick updates later
        this._orderRowKeyCache.set(orderId, row.id);
        
        rowData.push({ id: row.id, data });
      }
      
      // Fetch all stores in parallel with caching
      const fetchStartTime = Date.now();
      const storeCache = new Map();
      const storePromises = Array.from(storeIds).map(async (storeId) => {
        const store = await this.getStoreWithCache(storeId);
        storeCache.set(storeId, store);
      });
      
      // Fetch all users in parallel with caching
      const userCache = new Map();
      const userPromises = Array.from(userIds).map(async (userId) => {
        const user = await this.getUserWithCache(userId);
        userCache.set(userId, user);
      });
      
      await Promise.all([...storePromises, ...userPromises]);
      console.log(`Orders: Fetched ${storeIds.size} stores and ${userIds.size} users in ${Date.now() - fetchStartTime}ms`);

      // Now parse orders with cached stores and users
      const parseStartTime = Date.now();
      const orders = [];
      for (const { id, data } of rowData) {
        const order = await this.parseOrderDataWithCache(id, data, storeCache, userCache);
        orders.push(order);
      }
      console.log(`Orders: Parsed ${orders.length} orders in ${Date.now() - parseStartTime}ms`);

      const totalTime = Date.now() - startTime;
      console.log(`Orders: getAllOrders completed in ${totalTime}ms (${orders.length} orders)`);
      return orders;
    } catch (error) {
      console.error('Error getting all orders:', error.message);
      // Return empty array if there's an error
      return [];
    }
  }
}

module.exports = new OrderService();


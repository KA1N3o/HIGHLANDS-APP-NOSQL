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
const Order = require('../models/Order');

class OrderService {
  /**
   * Create a new order
   */
  async createOrder(userId, orderData) {
    const { storeId, items, paymentMethod, notes, deliveryAddress, promotionCode } = orderData;
    
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
    const deliveryFee = 15000; // Fixed delivery fee
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
      deliveryAddress: deliveryAddress || null,  // Return object or null, not JSON string
      orderTime: orderTime,
      notes: notes || '',
      promotionCode: promotionCode || null,  // Return null if not provided
    };
  }

  /**
   * Get orders for a specific user
   */
  async getUserOrders(userId, limit = 50) {
    const ordersByUserTable = tables.ordersByUser;
    const ordersTable = tables.orders;

    // Query user's order index
    const [indexRows] = await ordersByUserTable.getRows({
      prefix: `${userId}#order#`,
      limit,
    });

    const orders = [];

    for (const indexRow of indexRows) {
      const indexData = parseRowData(indexRow);
      const orderRowKey = indexData.orderRowKey;

      // Get full order data
      const orderRow = ordersTable.row(orderRowKey);
      const [orderData] = await orderRow.get();

      if (orderData) {
        const order = await this.parseOrderData(orderRowKey, orderData);
        orders.push(order);
      }
    }

    return orders;
  }

  /**
   * Get order by ID
   */
  async getOrderById(orderId) {
    const ordersTable = tables.orders;

    // Find order by partial key match
    const [rows] = await ordersTable.getRows();
    
    console.log(`DEBUG: Searching for order with ID: ${orderId}`);
    console.log(`DEBUG: Found ${rows.length} total order rows`);
    
    const orderRow = rows.find((row) => {
      const matches = row.id.endsWith(`#${orderId}`);
      console.log(`DEBUG: Checking row ${row.id} - matches: ${matches}`);
      return matches;
    });

    if (!orderRow) {
      console.log(`DEBUG: Order not found for ID: ${orderId}`);
      throw new Error('Order not found');
    }

    console.log(`DEBUG: Found order row:`, JSON.stringify(orderRow, null, 2));
    return this.parseOrderData(orderRow.id, orderRow);
  }

  /**
   * Update order status
   */
  async updateOrderStatus(orderId, status) {
    const ordersTable = tables.orders;

    // Find order
    const [rows] = await ordersTable.getRows();
    const orderRow = rows.find((row) => row.id.endsWith(`#${orderId}`));

    if (!orderRow) {
      throw new Error('Order not found');
    }

    const row = ordersTable.row(orderRow.id);
    
    const updateData = { status };
    
    // Add timestamps based on status
    if (status === 'confirmed') {
      updateData.confirmedTime = new Date().toISOString();
    } else if (status === 'completed') {
      updateData.completedTime = new Date().toISOString();
    } else if (status === 'cancelled') {
      updateData.cancelledTime = new Date().toISOString();
    }
    
    const mutations = createMutations('info', updateData);
    await row.save(mutations);

    // Update delivery status if status is delivering
    if (status === 'delivering') {
      try {
        const delivery = await deliveryService.getDeliveryByOrderId(orderId);
        await deliveryService.updateDeliveryStatus(delivery.id, 'delivering');
      } catch (error) {
        console.log('No delivery record found for order:', orderId);
      }
    } else if (status === 'completed') {
      try {
        const delivery = await deliveryService.getDeliveryByOrderId(orderId);
        await deliveryService.updateDeliveryStatus(delivery.id, 'delivered', {
          actualDeliveryTime: new Date().toISOString(),
        });
      } catch (error) {
        console.log('No delivery record found for order:', orderId);
      }
    }

    return this.getOrderById(orderId);
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
    const [rows] = await ordersTable.getRows();
    const orderRow = rows.find((row) => row.id.endsWith(`#${orderId}`));

    const row = ordersTable.row(orderRow.id);
    
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

    // Find order
    const [rows] = await ordersTable.getRows();
    const orderRow = rows.find((row) => row.id.endsWith(`#${orderId}`));

    if (!orderRow) {
      throw new Error('Order not found');
    }

    const row = ordersTable.row(orderRow.id);
    
    const mutations = createMutations('payment', { status: paymentStatus });
    await row.save(mutations);

    return this.getOrderById(orderId);
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
          console.log(`DEBUG: Parsing item ${key}: ${value}`);
          // Handle escaped characters properly
          let cleanValue = value;
          // First decode any escaped sequences
          if (typeof value === 'string') {
            // Handle hex escape sequences
            cleanValue = value.replace(/\\x([0-9A-Fa-f]{2})/g, (match, hex) => {
              return String.fromCharCode(parseInt(hex, 16));
            });
            // Handle double escaped sequences
            cleanValue = cleanValue.replace(/\\\\x([0-9A-Fa-f]{2})/g, (match, hex) => {
              return String.fromCharCode(parseInt(hex, 16));
            });
          }
          const itemData = JSON.parse(cleanValue);
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
  async getAllOrders(limit = 100) {
    const ordersTable = tables.orders;
    
    const [rows] = await ordersTable.getRows({ limit });

    const orders = [];
    for (const row of rows) {
      const order = await this.parseOrderData(row.id, row);
      orders.push(order);
    }

    return orders;
  }
}

module.exports = new OrderService();


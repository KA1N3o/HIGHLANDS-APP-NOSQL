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

    // Validate store exists
    const store = await storeService.getStoreById(storeId);

    // Calculate totals
    let subtotal = 0;
    const orderItems = [];

    for (const item of items) {
      const product = await productService.getProductById(item.productId);
      
      if (!product.isAvailable) {
        throw new Error(`Product ${product.name} is not available`);
      }

      const itemTotal = product.price * item.quantity;
      subtotal += itemTotal;

      orderItems.push({
        productId: item.productId,
        name: product.name,
        price: product.price,
        quantity: item.quantity,
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
      userId,
      storeId,
      orderTime,
      status: 'pending',
      notes: notes || '',
      deliveryAddress: JSON.stringify(deliveryAddress || {}),
      promotionCode: promotionCode || '',
    });

    const paymentMutations = createMutations('payment', {
      method: paymentMethod,
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
        orderId,
        deliveryAddress,
        pickupAddress: {
          name: store.name,
          address: store.address,
          lat: store.latitude,
          lng: store.longitude,
        },
        status: 'pending',
      });
    }

    return {
      id: orderId,
      userId,
      store,
      items: orderItems,
      subtotal,
      tax,
      deliveryFee,
      discount,
      total,
      status: 'pending',
      paymentMethod,
      paymentStatus: 'pending',
      deliveryAddress,
      orderTime,
      notes: notes || null,
      promotionCode: promotionCode || null,
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
    
    const orderRow = rows.find((row) => row.id.endsWith(`#${orderId}`));

    if (!orderRow) {
      throw new Error('Order not found');
    }

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
    const data = parseRowData(rowData);

    // Extract order ID from row key
    const orderId = rowKey.split('#').pop();

    // Parse items
    const items = [];
    for (const [key, value] of Object.entries(data)) {
      if (key.startsWith('item_')) {
        try {
          items.push(JSON.parse(value));
        } catch {
          // Skip invalid items
        }
      }
    }

    // Get store data
    let store = null;
    try {
      store = await storeService.getStoreById(data.storeId);
    } catch {
      store = { id: data.storeId, name: 'Unknown Store' };
    }

    return {
      id: orderId,
      userId: data.userId,
      store,
      items,
      subtotal: parseFloat(data.subtotal),
      tax: parseFloat(data.tax),
      total: parseFloat(data.total),
      status: data.status,
      paymentMethod: data.method,
      paymentStatus: data.status,
      orderTime: data.orderTime,
      pickupTime: data.pickupTime || null,
      completedTime: data.completedTime || null,
      notes: data.notes || null,
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


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

class OrderService {
  /**
   * Create a new order
   */
  async createOrder(userId, orderData) {
    const { storeId, items, paymentMethod, notes } = orderData;

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
    const total = subtotal + tax;

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
    });

    const paymentMutations = createMutations('payment', {
      method: paymentMethod,
      status: 'pending',
      subtotal: String(subtotal),
      tax: String(tax),
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

    return {
      id: orderId,
      userId,
      store,
      items: orderItems,
      subtotal,
      tax,
      total,
      status: 'pending',
      paymentMethod,
      paymentStatus: 'pending',
      orderTime,
      notes: notes || null,
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
    
    const mutations = createMutations('info', { status });
    
    // Add completed time if status is completed
    if (status === 'completed') {
      mutations.push({
        method: 'insert',
        data: {
          columnFamily: 'info',
          column: 'completedTime',
          value: new Date().toISOString(),
        },
      });
    }

    await row.save(mutations);

    return this.parseOrderData(orderRow.id, orderRow);
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


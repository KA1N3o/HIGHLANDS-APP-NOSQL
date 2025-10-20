const orderService = require('./src/services/orderService');
const storeService = require('./src/services/storeService');

async function testOrderParsing() {
  try {
    console.log('Testing order parsing...');
    
    // Get a store to use for the order
    const stores = await storeService.getAllStores();
    if (stores.length === 0) {
      console.log('No stores available');
      return;
    }
    
    const store = stores[0];
    
    // Create a test order
    const orderData = {
      storeId: store.id,
      items: [
        {
          productId: 'product#cf001',
          quantity: 1,
          size: 'Medium',
          options: []
        }
      ],
      paymentMethod: 'cash',
      notes: 'Test order'
    };
    
    const userId = 'user#test123';
    const order = await orderService.createOrder(userId, orderData);
    console.log('Order created successfully');
    
    // Now test parsing the order
    const parsedOrder = await orderService.getOrderById(order.id);
    console.log('Parsed order:', JSON.stringify(parsedOrder, null, 2));
    
  } catch (error) {
    console.error('Error:', error.message);
    console.error('Stack:', error.stack);
  }
}

testOrderParsing();
const orderService = require('./src/services/orderService');
const storeService = require('./src/services/storeService');

async function testOrderCreation() {
  try {
    console.log('Testing order creation...');
    
    // Get a store to use for the order
    const stores = await storeService.getAllStores();
    if (stores.length === 0) {
      console.log('No stores available');
      return;
    }
    
    const store = stores[0];
    console.log('Using store:', JSON.stringify(store, null, 2));
    
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
    console.log('Order created successfully:', JSON.stringify(order, null, 2));
    
  } catch (error) {
    console.error('Error:', error.message);
    console.error('Stack:', error.stack);
  }
}

testOrderCreation();
const express = require('express');
const orderService = require('./src/services/orderService');
const storeService = require('./src/services/storeService');
const { successResponse } = require('./src/utils/helpers');

const app = express();
app.use(express.json());

app.get('/test-order-response', async (req, res) => {
  try {
    // Get a store to use for the order
    const stores = await storeService.getAllStores();
    if (stores.length === 0) {
      return res.status(404).json({ error: 'No stores available' });
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
    const response = successResponse(order, 'Order created successfully');
    
    console.log('API Response Structure:', JSON.stringify(response, null, 2));
    res.json(response);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(3002, () => {
  console.log('Test server running on port 3002');
});
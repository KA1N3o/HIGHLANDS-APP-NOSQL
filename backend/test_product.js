process.env.NODE_ENV = 'development';

const productService = require('./src/services/productService');

async function testProductService() {
  try {
    console.log('Testing product service...');
    
    // Test getting a product
    console.log('Getting product product#cf001...');
    const product = await productService.getProductById('product#cf001');
    
    console.log('Product found:');
    console.log('ID:', product.id);
    console.log('Name:', product.name);
    console.log('Price:', product.price);
    console.log('Available:', product.isAvailable);
    
    if (product.name) {
      console.log('✅ Product retrieval is working correctly!');
    } else {
      console.log('❌ Product name is missing');
    }
  } catch (error) {
    console.error('Error:', error.message);
    console.error('Stack:', error.stack);
  }
}

testProductService();
const { tables } = require('./src/config/bigtable');

async function testAdapter() {
  try {
    console.log('Testing HBase Docker Adapter...');
    
    // Test getting a product
    const productsTable = tables.products;
    const row = productsTable.row('product#cf001');
    
    console.log('Getting product data...');
    const [data] = await row.get();
    
    console.log('Raw data:', JSON.stringify(data, null, 2));
    
    if (data) {
      console.log('Data keys:', Object.keys(data));
      if (data.data) {
        console.log('Data.data keys:', Object.keys(data.data));
        Object.keys(data.data).forEach(family => {
          console.log(`Family ${family} keys:`, Object.keys(data.data[family]));
        });
      }
    } else {
      console.log('No data returned');
    }
  } catch (error) {
    console.error('Error:', error.message);
    console.error('Stack:', error.stack);
  }
}

testAdapter();
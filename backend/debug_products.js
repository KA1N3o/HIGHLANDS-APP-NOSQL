// Debug script to check products in Bigtable
const { tables } = require('./src/config/bigtable');
const { parseRowData } = require('./src/utils/helpers');

async function debugProducts() {
  try {
    console.log('Fetching products from Bigtable...');
    const productsTable = tables.products;
    const [rows] = await productsTable.getRows();
    
    console.log(`\nTotal products: ${rows.length}\n`);
    
    rows.forEach((row, index) => {
      const data = parseRowData(row.data || row);
      console.log(`${index + 1}. ID: ${row.id}`);
      console.log(`   Name: ${data.name || 'N/A'}`);
      console.log(`   Price: ${data.price || 'N/A'}`);
      console.log(`   Category: ${data.category || 'N/A'}`);
      console.log(`   Available: ${data.isAvailable || 'N/A'}`);
      console.log('');
    });
    
    process.exit(0);
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

debugProducts();


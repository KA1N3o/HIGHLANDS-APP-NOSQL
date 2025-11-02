const { tables } = require('./src/config/bigtable');
const { parseRowData } = require('./src/utils/helpers');

async function debug() {
  console.log('Fetching promotions from Bigtable...\n');
  
  const promotionsTable = tables.promotions;
  const [rows] = await promotionsTable.getRows();
  
  console.log(`Got ${rows.length} rows\n`);
  
  for (const row of rows) {
    console.log(`=== Row ID: ${row.id} ===`);
    console.log('Row keys:', Object.keys(row));
    console.log('Row.data exists?', !!row.data);
    
    if (row.data) {
      console.log('Row.data keys:', Object.keys(row.data));
      console.log('Row.data:', JSON.stringify(row.data, null, 2));
    }
    
    console.log('\nTrying to parse with parseRowData(row):');
    const parsed1 = parseRowData(row);
    console.log(JSON.stringify(parsed1, null, 2));
    
    console.log('\nTrying to parse with parseRowData(row.data):');
    const parsed2 = parseRowData(row.data);
    console.log(JSON.stringify(parsed2, null, 2));
    
    console.log('\n---\n');
  }
  
  process.exit(0);
}

debug().catch(console.error);




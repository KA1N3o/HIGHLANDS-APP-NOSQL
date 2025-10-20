/**
 * Bigtable Configuration
 * 
 * Chế độ phát triển: Sử dụng HBase local thay vì Google Cloud Bigtable
 * Chế độ production: Sử dụng Google Cloud Bigtable
 */

// Check environment to decide which implementation to use
const USE_HBASE = process.env.NODE_ENV === 'development' || process.env.USE_HBASE === 'true';

let bigtable, instance, tables;

if (USE_HBASE) {
  // Use HBase adapter for local development
  console.log('🔧 Using HBase Docker for development');
  
  // Use Docker adapter (HBase in Docker container)
  const hbaseDockerAdapter = require('./hbase-docker-adapter');
  
  bigtable = hbaseDockerAdapter.bigtable;
  instance = hbaseDockerAdapter.instance;
  tables = hbaseDockerAdapter.tables;
} else {
  // Use Google Cloud Bigtable for production
  console.log('☁️ Using Google Cloud Bigtable');
  const { Bigtable } = require('@google-cloud/bigtable');
  
  bigtable = new Bigtable({
    projectId: process.env.GCP_PROJECT_ID,
  });

  instance = bigtable.instance(process.env.BIGTABLE_INSTANCE_ID);

  tables = {
    users: instance.table('users'),
    products: instance.table('products'),
    stores: instance.table('stores'),
    orders: instance.table('orders'),
    ordersByUser: instance.table('orders_by_user'),
    sessions: instance.table('sessions'),
    carts: instance.table('carts'),
    deliveries: instance.table('deliveries'),
    promotions: instance.table('promotions'),
    payments: instance.table('payments'),
  };
}

module.exports = {
  bigtable,
  instance,
  tables,
};


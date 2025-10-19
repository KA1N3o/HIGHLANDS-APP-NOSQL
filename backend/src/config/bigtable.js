const { Bigtable } = require('@google-cloud/bigtable');

// Initialize Bigtable client
const bigtable = new Bigtable({
  projectId: process.env.GCP_PROJECT_ID,
  // Credentials are automatically loaded from:
  // 1. GOOGLE_APPLICATION_CREDENTIALS environment variable
  // 2. Application Default Credentials (when running on GCP)
});

const instance = bigtable.instance(process.env.BIGTABLE_INSTANCE_ID);

// Table references
const tables = {
  users: instance.table('users'),
  products: instance.table('products'),
  stores: instance.table('stores'),
  orders: instance.table('orders'),
  ordersByUser: instance.table('orders_by_user'),
  sessions: instance.table('sessions'),
};

module.exports = {
  bigtable,
  instance,
  tables,
};


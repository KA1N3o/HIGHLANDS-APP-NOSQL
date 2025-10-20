const hbase = require('hbase');

// Initialize HBase client for local HBase
const client = hbase({
  host: process.env.HBASE_HOST || 'localhost',
  port: process.env.HBASE_PORT || 8080, // HBase REST server port
  // For HBase Thrift, use port 9090
  // For HBase REST API, use port 8080
});

// Alternative: If using HBase via Thrift
// const thrift = require('thrift');
// const HBase = require('./hbase-thrift/HBase');
// const HBaseTypes = require('./hbase-thrift/HBase_types');

// Helper function to create table reference
function getTable(tableName) {
  return client.table(tableName);
}

// Helper function to scan table
async function scanTable(tableName, options = {}) {
  return new Promise((resolve, reject) => {
    const table = getTable(tableName);
    const scanner = table.scan(options);
    const rows = [];

    scanner.on('readable', function() {
      let row;
      while ((row = this.read()) !== null) {
        rows.push(row);
      }
    });

    scanner.on('error', function(err) {
      reject(err);
    });

    scanner.on('end', function() {
      resolve(rows);
    });
  });
}

// Helper function to get single row
async function getRow(tableName, rowKey) {
  return new Promise((resolve, reject) => {
    const table = getTable(tableName);
    
    table.row(rowKey).get((err, cells) => {
      if (err) {
        reject(err);
      } else {
        resolve(cells);
      }
    });
  });
}

// Helper function to put (insert/update) row
async function putRow(tableName, rowKey, data) {
  return new Promise((resolve, reject) => {
    const table = getTable(tableName);
    
    // Convert data object to HBase format
    // data format: { 'columnFamily:column': 'value' }
    table.row(rowKey).put(data, (err, success) => {
      if (err) {
        reject(err);
      } else {
        resolve(success);
      }
    });
  });
}

// Helper function to delete row
async function deleteRow(tableName, rowKey) {
  return new Promise((resolve, reject) => {
    const table = getTable(tableName);
    
    table.row(rowKey).delete((err, success) => {
      if (err) {
        reject(err);
      } else {
        resolve(success);
      }
    });
  });
}

// Helper function to parse HBase cells to JSON
function cellsToJson(cells) {
  if (!cells || cells.length === 0) {
    return null;
  }

  const result = {};
  
  cells.forEach(cell => {
    const columnParts = cell.column.split(':');
    const family = columnParts[0];
    const qualifier = columnParts[1];
    
    if (!result[family]) {
      result[family] = {};
    }
    
    // Convert buffer to string
    const value = cell.$ || cell.value;
    result[family][qualifier] = value ? value.toString() : null;
  });

  return result;
}

// Helper function to convert JSON to HBase cells format
function jsonToCells(data) {
  const cells = [];
  
  Object.keys(data).forEach(family => {
    Object.keys(data[family]).forEach(qualifier => {
      cells.push({
        column: `${family}:${qualifier}`,
        $: data[family][qualifier]
      });
    });
  });
  
  return cells;
}

// Table references (for compatibility with existing code)
const tables = {
  users: 'users',
  products: 'products',
  stores: 'stores',
  orders: 'orders',
  ordersByUser: 'orders_by_user',
  sessions: 'sessions',
  carts: 'carts',
  deliveries: 'deliveries',
  promotions: 'promotions',
  payments: 'payments',
};

module.exports = {
  client,
  getTable,
  scanTable,
  getRow,
  putRow,
  deleteRow,
  cellsToJson,
  jsonToCells,
  tables,
};



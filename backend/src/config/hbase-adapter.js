const hbase = require('hbase');

/**
 * HBase Adapter - Giả lập Google Bigtable API nhưng dùng HBase
 * Điều này giúp tương thích với code hiện tại mà không cần sửa tất cả service files
 */

class HBaseAdapter {
  constructor() {
    this.client = hbase({
      host: process.env.HBASE_HOST || 'localhost',
      port: parseInt(process.env.HBASE_PORT) || 8080,
    });
  }

  // Giả lập bigtable.instance()
  instance(instanceId) {
    return {
      table: (tableName) => this.createTableWrapper(tableName)
    };
  }

  createTableWrapper(tableName) {
    const hbaseTable = this.client.table(tableName);

    return {
      // Giả lập row() method
      row: (rowKey) => ({
        get: async () => {
          return new Promise((resolve, reject) => {
            hbaseTable.row(rowKey).get((err, cells) => {
              if (err) {
                reject(err);
                return;
              }
              
              if (!cells || cells.length === 0) {
                resolve([null]); // Bigtable returns [null] when not found
                return;
              }

              // Convert HBase cells to Bigtable-like format
              const bigtableData = this.cellsToBigtableFormat(cells);
              resolve([bigtableData]);
            });
          });
        },

        save: async (data) => {
          // Convert Bigtable mutations to HBase format
          const hbaseCells = this.bigtableToCells(data);
          
          return new Promise((resolve, reject) => {
            hbaseTable.row(rowKey).put(hbaseCells, (err, success) => {
              if (err) {
                reject(err);
              } else {
                resolve();
              }
            });
          });
        },

        delete: async () => {
          return new Promise((resolve, reject) => {
            hbaseTable.row(rowKey).delete((err) => {
              if (err) {
                reject(err);
              } else {
                resolve();
              }
            });
          });
        },

        // For mutations/batch operations
        create: (mutations) => {
          return {
            commit: async () => {
              const hbaseCells = this.mutationsToCells(mutations);
              return new Promise((resolve, reject) => {
                hbaseTable.row(rowKey).put(hbaseCells, (err) => {
                  if (err) {
                    reject(err);
                  } else {
                    resolve();
                  }
                });
              });
            }
          };
        }
      }),

      // Giả lập getRows() method
      getRows: async (options = {}) => {
        return new Promise((resolve, reject) => {
          const scanner = hbaseTable.scan(options);
          const rows = [];

          scanner.on('readable', function() {
            let cell;
            while ((cell = this.read()) !== null) {
              const rowKey = cell.key.toString();
              
              // Group cells by row
              let existingRow = rows.find(r => r.id === rowKey);
              if (!existingRow) {
                existingRow = {
                  id: rowKey,
                  data: {}
                };
                rows.push(existingRow);
              }

              // Parse cell
              const columnParts = cell.column.split(':');
              const family = columnParts[0];
              const qualifier = columnParts[1];
              const value = cell.$ ? cell.$.toString() : '';

              if (!existingRow.data[family]) {
                existingRow.data[family] = {};
              }
              existingRow.data[family][qualifier] = [{
                value: value,
                timestamp: cell.timestamp || Date.now()
              }];
            }
          });

          scanner.on('error', (err) => {
            reject(err);
          });

          scanner.on('end', () => {
            resolve([rows]);
          });
        });
      },

      // Giả lập createReadStream() method
      createReadStream: (options = {}) => {
        return hbaseTable.scan(options);
      }
    };
  }

  // Convert HBase cells to Bigtable format
  cellsToBigtableFormat(cells) {
    const bigtableData = {};

    cells.forEach(cell => {
      const columnParts = cell.column.split(':');
      const family = columnParts[0];
      const qualifier = columnParts[1];
      const value = cell.$ ? cell.$.toString() : '';

      if (!bigtableData[family]) {
        bigtableData[family] = {};
      }

      // Bigtable format: family.qualifier = [{ value, timestamp }]
      bigtableData[family][qualifier] = [{
        value: value,
        timestamp: cell.timestamp || Date.now()
      }];
    });

    return bigtableData;
  }

  // Convert Bigtable data to HBase cells
  bigtableToCells(data) {
    const cells = [];

    Object.keys(data).forEach(family => {
      Object.keys(data[family]).forEach(qualifier => {
        const columnData = data[family][qualifier];
        
        // Handle both formats: 
        // 1. [{ value, timestamp }]
        // 2. Direct value
        let value;
        if (Array.isArray(columnData) && columnData.length > 0) {
          value = columnData[0].value;
        } else {
          value = columnData;
        }

        cells.push({
          column: `${family}:${qualifier}`,
          $: value,
          timestamp: Date.now()
        });
      });
    });

    return cells;
  }

  // Convert Bigtable mutations to HBase cells
  mutationsToCells(mutations) {
    const cells = [];

    // Mutations format from Bigtable: { columnFamily: { qualifier: value } }
    Object.keys(mutations).forEach(family => {
      Object.keys(mutations[family]).forEach(qualifier => {
        cells.push({
          column: `${family}:${qualifier}`,
          $: mutations[family][qualifier]
        });
      });
    });

    return cells;
  }
}

// Create singleton instance
const hbaseAdapter = new HBaseAdapter();

// Export in Bigtable-compatible format
const instance = hbaseAdapter.instance(process.env.BIGTABLE_INSTANCE_ID || 'highlands-coffee');

const tables = {
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

module.exports = {
  bigtable: hbaseAdapter,
  instance,
  tables,
};



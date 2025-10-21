const { exec, spawn } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);
const iconv = require('iconv-lite');

/**
 * HBase Docker Adapter - Sử dụng HBase shell commands qua Docker
 * Phù hợp cho development với HBase chạy trong Docker container
 */

const DOCKER_CONTAINER = process.env.HBASE_DOCKER_CONTAINER || 'hbase';

class HBaseDockerAdapter {
  constructor() {
    this.containerName = DOCKER_CONTAINER;
  }

  // Execute HBase shell command
  async executeHBaseCommand(command) {
    return new Promise((resolve, reject) => {
      const process = spawn('docker', [
        'exec',
        '-i',
        this.containerName,
        '/opt/hbase-1.2.6/bin/hbase',
        'shell',
        '-n'
      ]);

      let stdout = '';
      let stderr = '';

      process.stdout.on('data', (data) => {
        stdout += data.toString('utf8');
      });
      
      process.stderr.on('data', (data) => {
        stderr += data.toString('utf8');
      });

      process.on('close', (code) => {
        if (code !== 0 && !stdout) {
          reject(new Error(`HBase command failed with code ${code}: ${stderr}`));
        } else {
          resolve(stdout);
        }
      });

      process.on('error', (error) => {
        reject(error);
      });

      // Write command to stdin
      process.stdin.write(command + '\n');
      process.stdin.end();
    });
  }

  // Parse HBase shell output to JSON
  parseShellOutput(output) {
    const lines = output.split('\n').filter(line => 
      line.trim() && 
      !line.includes('HBase Shell') && 
      !line.includes('row(s)') &&
      !line.includes('Took ')
    );
    return lines;
  }

  // Giả lập bigtable.instance()
  instance(instanceId) {
    return {
      table: (tableName) => this.createTableWrapper(tableName)
    };
  }

  createTableWrapper(tableName) {
    return {
      // Giả lập row() method
      row: (rowKey) => ({
        get: async () => {
          try {
            const command = `get '${tableName}', '${rowKey}'`;
            console.log(`Executing HBase GET command: ${command}`);
            const output = await this.executeHBaseCommand(command);
            console.log(`HBase GET output for ${rowKey}:`, output);
            
            if (output.includes('0 row(s)') || !output.trim()) {
              console.log(`No data found for row ${rowKey}`);
              return [null];
            }

            const data = this.parseGetOutput(output);
            console.log(`Parsed GET data for ${rowKey}:`, JSON.stringify(data, null, 2));
            return [data];
          } catch (error) {
            console.error(`Error getting row ${rowKey}:`, error.message);
            return [null];
          }
        },

        save: async (data) => {
          try {
            let putCommands;
            
            // Check if data is array of mutations (Bigtable format from createMutations helper)
            if (Array.isArray(data)) {
              putCommands = [];
              data.forEach(mutation => {
                if (mutation.method === 'insert' && mutation.data) {
                  const { columnFamily, column, value } = mutation.data;
                  const escapedValue = String(value).replace(/'/g, "\\'");
                  const cmd = `put '${tableName}', '${rowKey}', '${columnFamily}:${column}', '${escapedValue}'`;
                  console.log(`HBase PUT command: ${cmd}`);
                  putCommands.push(cmd);
                }
              });
            } else {
              // Object format
              putCommands = this.createPutCommands(tableName, rowKey, data);
            }
            
            // Batch all commands into one execution for better performance
            const batchCommand = putCommands.join('\n');
            console.log(`Executing ${putCommands.length} HBase PUT commands for row ${rowKey}`);
            await this.executeHBaseCommand(batchCommand);
            console.log(`Successfully executed HBase PUT commands for row ${rowKey}`);
          } catch (error) {
            console.error(`Error saving row ${rowKey}:`, error.message);
            throw error;
          }
        },

        delete: async () => {
          try {
            const command = `deleteall '${tableName}', '${rowKey}'`;
            await this.executeHBaseCommand(command);
          } catch (error) {
            console.error(`Error deleting row ${rowKey}:`, error.message);
            throw error;
          }
        },

        create: (mutations) => {
          return {
            commit: async () => {
              try {
                const putCommands = this.createPutCommandsFromMutations(tableName, rowKey, mutations);
                
                for (const cmd of putCommands) {
                  await this.executeHBaseCommand(cmd);
                }
              } catch (error) {
                console.error(`Error committing mutations for ${rowKey}:`, error.message);
                throw error;
              }
            }
          };
        }
      }),

      // Giả lập getRows() method
      getRows: async (options = {}) => {
        try {
          let command = `scan '${tableName}'`;
          
          if (options.limit) {
            command += `, {LIMIT => ${options.limit}}`;
          }

          const output = await this.executeHBaseCommand(command);
          const rows = this.parseScanOutput(output);
          
          return [rows];
        } catch (error) {
          console.error(`Error scanning table ${tableName}:`, error.message);
          return [[]];
        }
      },

      createReadStream: (options = {}) => {
        // For compatibility - return a promise that resolves to rows
        return this.getRows(options);
      }
    };
  }

  // Parse 'get' command output
  parseGetOutput(output) {
    const data = {};
    const lines = output.split('\n');
    
    lines.forEach(line => {
      // Format: "family:qualifier timestamp=xxx, value=yyy"
      // Skip the header line that contains "COLUMN  CELL"
      if (line.includes('COLUMN') && line.includes('CELL')) {
        return;
      }
      
      const columnMatch = line.match(/^\s*(\w+):(\w+)\s+timestamp=\d+,\s+value=(.+)$/);
      if (columnMatch) {
        const [, family, qualifier, value] = columnMatch;
        
        if (!data[family]) {
          data[family] = {};
        }
        
        // Properly decode UTF-8 values
        const decodedValue = this.decodeUTF8Value(value.trim());
        
        data[family][qualifier] = [{
          value: decodedValue,
          timestamp: Date.now()
        }];
      }
    });
    
    return data;
  }

  // Parse 'scan' command output
  parseScanOutput(output) {
    const rows = [];
    const lines = output.split('\n');
    let currentRow = null;
    
    lines.forEach(line => {
      // Skip the header line that contains "ROW  COLUMN+CELL"
      if (line.includes('ROW') && line.includes('COLUMN+CELL')) {
        return;
      }
      
      // Skip lines that contain row count info
      if (line.includes('row(s) in')) {
        return;
      }
      
      // Skip empty lines
      if (!line.trim()) {
        return;
      }
      
      // Row key line format: "rowkey column=family:qualifier, timestamp=xxx, value=yyy"
      const rowMatch = line.match(/^\s*(\S+)\s+column=(\w+):(\w+),\s+timestamp=\d+,\s+value=(.+)$/);
      if (rowMatch) {
        const [, rowKey, family, qualifier, value] = rowMatch;
        
        // Log when we find a status column
        if (qualifier === 'status') {
          console.log(`parseScanOutput: Found status for row ${rowKey}: ${value}`);
        }
        
        // Check if we need to start a new row
        if (!currentRow || currentRow.id !== rowKey) {
          if (currentRow) {
            rows.push(currentRow);
          }
          currentRow = {
            id: rowKey,
            data: {}
          };
        }
        
        if (!currentRow.data[family]) {
          currentRow.data[family] = {};
        }
        
        // Properly decode UTF-8 values
        const decodedValue = this.decodeUTF8Value(value.trim());
        
        currentRow.data[family][qualifier] = [{
          value: decodedValue,
          timestamp: Date.now()
        }];
        
        // Log the decoded value for status
        if (qualifier === 'status') {
          console.log(`parseScanOutput: Decoded status value: ${decodedValue}`);
        }
      }
    });
    
    if (currentRow) {
      rows.push(currentRow);
    }
    
    console.log(`parseScanOutput: Parsed ${rows.length} rows`);
    return rows;
  }

  // Helper function to decode UTF-8 values
  decodeUTF8Value(value) {
    try {
      // Handle escaped Unicode sequences
      let decodedValue = value.replace(/\\x([0-9A-Fa-f]{2})/g, (match, hex) => {
        return String.fromCharCode(parseInt(hex, 16));
      });
      
      // Handle double escaped sequences
      decodedValue = decodedValue.replace(/\\\\x([0-9A-Fa-f]{2})/g, (match, hex) => {
        return String.fromCharCode(parseInt(hex, 16));
      });
      
      return decodedValue;
    } catch (error) {
      console.warn('Error decoding UTF-8 value:', error.message);
      return value;
    }
  }

  // Create PUT commands from Bigtable-style data
  createPutCommands(tableName, rowKey, data) {
    const commands = [];
    
    Object.keys(data).forEach(family => {
      Object.keys(data[family]).forEach(qualifier => {
        const columnData = data[family][qualifier];
        let value;
        
        if (Array.isArray(columnData) && columnData.length > 0) {
          value = columnData[0].value;
        } else {
          value = columnData;
        }
        
        // Escape single quotes in value
        const escapedValue = String(value).replace(/'/g, "\\'");
        commands.push(`put '${tableName}', '${rowKey}', '${family}:${qualifier}', '${escapedValue}'`);
      });
    });
    
    return commands;
  }

  // Create PUT commands from mutations
  createPutCommandsFromMutations(tableName, rowKey, mutations) {
    const commands = [];
    
    Object.keys(mutations).forEach(family => {
      Object.keys(mutations[family]).forEach(qualifier => {
        const value = mutations[family][qualifier];
        const escapedValue = String(value).replace(/'/g, "\\'");
        commands.push(`put '${tableName}', '${rowKey}', '${family}:${qualifier}', '${escapedValue}'`);
      });
    });
    
    return commands;
  }
}

// Create singleton instance
const hbaseDockerAdapter = new HBaseDockerAdapter();

// Export in Bigtable-compatible format
const instance = hbaseDockerAdapter.instance(process.env.BIGTABLE_INSTANCE_ID || 'highlands-coffee');

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
  bigtable: hbaseDockerAdapter,
  instance,
  tables,
};
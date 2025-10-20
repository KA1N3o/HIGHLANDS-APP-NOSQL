/**
 * Convert a timestamp to reversed timestamp for Bigtable row keys
 * This allows for efficient time-range queries (most recent first)
 */
function getReversedTimestamp() {
  const maxTimestamp = Math.pow(2, 63) - 1; // Max value for signed 64-bit integer
  return maxTimestamp - Date.now();
}

/**
 * Parse Bigtable row data into a JavaScript object
 */
function parseRowData(row) {
  const data = {};
  
  if (!row || !row.data) {
    return data;
  }

  for (const [family, columns] of Object.entries(row.data)) {
    for (const [column, cells] of Object.entries(columns)) {
      // Get the latest cell value
      if (cells && cells.length > 0) {
        const cellValue = cells[0].value;
        const key = `${family}:${column}`;
        
        // Try to parse JSON, otherwise use as string
        try {
          // Ensure proper UTF-8 decoding
          const stringValue = cellValue.toString('utf8');
          data[column] = JSON.parse(stringValue);
        } catch {
          // Ensure proper UTF-8 decoding for string values
          data[column] = cellValue.toString('utf8');
        }
      }
    }
  }

  return data;
}

/**
 * Create mutations for Bigtable row updates
 */
function createMutations(columnFamily, data) {
  const mutations = [];

  for (const [key, value] of Object.entries(data)) {
    if (value !== undefined && value !== null) {
      mutations.push({
        method: 'insert',
        data: {
          columnFamily,
          column: key,
          value: typeof value === 'object' ? JSON.stringify(value) : String(value),
        },
      });
    }
  }

  return mutations;
}

/**
 * Generate a unique ID with prefix
 */
function generateId(prefix = '') {
  const { v4: uuidv4 } = require('uuid');
  const id = uuidv4().split('-')[0]; // Use first part of UUID for shorter IDs
  return prefix ? `${prefix}${id}` : id;
}

/**
 * Calculate tax amount (10% VAT)
 */
function calculateTax(subtotal) {
  return Math.round(subtotal * 0.1);
}

/**
 * Format error response
 */
function errorResponse(message, statusCode = 500, errors = null) {
  return {
    success: false,
    error: {
      message,
      statusCode,
      errors,
    },
  };
}

/**
 * Format success response
 */
function successResponse(data, message = 'Success') {
  return {
    success: true,
    message,
    data,
  };
}

module.exports = {
  getReversedTimestamp,
  parseRowData,
  createMutations,
  generateId,
  calculateTax,
  errorResponse,
  successResponse,
};


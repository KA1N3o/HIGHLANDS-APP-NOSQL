const iconv = require('iconv-lite');

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
  
  if (!row) {
    return data;
  }

  // Helper function to extract cell value
  const getCellValue = (cells) => {
    if (!cells || cells.length === 0) return null;
    
    let cellValue;
    if (Array.isArray(cells) && cells.length > 0) {
      cellValue = cells[0].value;
    } else if (cells.value !== undefined) {
      cellValue = cells.value;
    } else {
      cellValue = cells;
    }
    
    // Try to parse JSON, otherwise use as string
    try {
      const stringValue = cellValue.toString();
      const decodedString = decodeEscapedUTF8(stringValue);
      return JSON.parse(decodedString);
    } catch {
      const stringValue = cellValue.toString();
      return decodeEscapedUTF8(stringValue);
    }
  };

  // Process all families EXCEPT 'info' first
  for (const [family, columns] of Object.entries(row)) {
    if (family === 'info') continue; // Skip 'info' for now
    
    for (const [column, cells] of Object.entries(columns)) {
      if (cells && cells.length > 0) {
        const value = getCellValue(cells);
        if (value !== null) {
          data[column] = value;
        }
      }
    }
  }
  
  // Process 'info' family LAST to ensure it overwrites any duplicate columns
  if (row.info) {
    for (const [column, cells] of Object.entries(row.info)) {
      if (cells && cells.length > 0) {
        const value = getCellValue(cells);
        if (value !== null) {
          data[column] = value;
          
        // Status set from info family (no log to improve performance)
        }
      }
    }
  }

  return data;
}

/**
 * Decode escaped UTF-8 sequences
 */
function decodeEscapedUTF8(str) {
  if (typeof str !== 'string') {
    return str;
  }
  
  try {
    // First, handle double escaped sequences (\\xXX -> \xXX)
    let decoded = str.replace(/\\\\x([0-9A-Fa-f]{2})/g, (match, hex) => {
      const charCode = parseInt(hex, 16);
      return String.fromCharCode(charCode);
    });
    
    // Then, handle single escaped sequences (\xXX -> actual character)
    decoded = decoded.replace(/\\x([0-9A-Fa-f]{2})/g, (match, hex) => {
      const charCode = parseInt(hex, 16);
      return String.fromCharCode(charCode);
    });
    
    // Use iconv-lite to properly decode UTF-8
    const buffer = Buffer.from(decoded, 'binary');
    return iconv.decode(buffer, 'utf8');
  } catch (error) {
    console.warn('Error decoding UTF-8 string:', error.message);
    return str;
  }
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
function successResponse(message, data = null) {
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
  decodeEscapedUTF8
};
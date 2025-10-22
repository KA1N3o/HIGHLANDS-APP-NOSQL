/**
 * Script to verify that admin changes are actually saved to Bigtable/HBase
 * This script tests:
 * 1. Product creation and retrieval
 * 2. Product update
 * 3. User role update
 */

const { tables } = require('./src/config/bigtable');
const productService = require('./src/services/productService');
const userService = require('./src/services/userService');
const { v4: uuidv4 } = require('uuid');

async function verifyProductChanges() {
  console.log('\n=== Testing Product Changes ===');
  
  // 1. Create a test product
  const testProductId = `product#test-${uuidv4().split('-')[0]}`;
  console.log(`\n1. Creating test product: ${testProductId}`);
  
  const testProduct = {
    id: testProductId,
    name: 'Test Product - Admin Verification',
    description: 'This is a test product to verify admin changes',
    price: 50000,
    imageUrl: 'https://example.com/test.jpg',
    category: 'coffee',
    isAvailable: true,
    preparationTime: 5,
    rating: 4.5,
    reviewCount: 0,
    sizes: ['Medium', 'Large'],
    options: [{ name: 'Đường', choices: ['Ít', 'Vừa', 'Nhiều'] }]
  };
  
  const createdProduct = await productService.createProduct(testProduct);
  console.log(`✓ Product created in service layer`);
  
  // 2. Verify it's in HBase by reading directly
  console.log(`\n2. Verifying product exists in HBase...`);
  const productsTable = tables.products;
  const row = productsTable.row(testProductId);
  const [data] = await row.get();
  
  if (!data) {
    console.error('✗ FAILED: Product not found in HBase!');
    return false;
  }
  console.log('✓ Product found in HBase');
  
  // 3. Update the product
  console.log(`\n3. Updating product...`);
  const updates = {
    name: 'Test Product - UPDATED',
    price: 60000,
    isAvailable: false
  };
  
  await productService.updateProduct(testProductId, updates);
  console.log('✓ Product updated in service layer');
  
  // 4. Verify update in HBase
  console.log(`\n4. Verifying update in HBase...`);
  const [updatedData] = await row.get();
  
  if (!updatedData) {
    console.error('✗ FAILED: Updated product not found in HBase!');
    return false;
  }
  
  // Parse the data
  const parseRowData = (rowData) => {
    const data = {};
    Object.keys(rowData).forEach(family => {
      Object.keys(rowData[family]).forEach(column => {
        const value = rowData[family][column][0].value;
        data[column] = value;
      });
    });
    return data;
  };
  
  const parsedData = parseRowData(updatedData.data || updatedData);
  console.log('Updated data in HBase:', JSON.stringify(parsedData, null, 2));
  
  if (parsedData.name !== 'Test Product - UPDATED') {
    console.error('✗ FAILED: Product name not updated in HBase!');
    return false;
  }
  
  if (parsedData.price !== '60000') {
    console.error('✗ FAILED: Product price not updated in HBase!');
    return false;
  }
  
  if (parsedData.isAvailable !== 'false') {
    console.error('✗ FAILED: Product availability not updated in HBase!');
    return false;
  }
  
  console.log('✓ All product fields correctly updated in HBase');
  
  // 5. Clean up - delete test product
  console.log(`\n5. Cleaning up test product...`);
  await productService.deleteProduct(testProductId);
  console.log('✓ Test product deleted');
  
  return true;
}

async function verifyUserChanges() {
  console.log('\n=== Testing User Changes ===');
  
  // Find a test user (or create one)
  console.log('\n1. Getting all users...');
  const users = await userService.getAllUsers(10);
  
  if (users.length === 0) {
    console.log('No users found to test with');
    return true;
  }
  
  // Use the first customer user for testing
  const testUser = users.find(u => u.role === 'customer') || users[0];
  console.log(`Found test user: ${testUser.email} (ID: ${testUser.id})`);
  
  // 2. Update user info
  console.log(`\n2. Updating user info...`);
  const originalName = testUser.name;
  const testName = `${originalName} [UPDATED ${Date.now()}]`;
  
  await userService.updateUser(testUser.id, {
    name: testName
  });
  console.log('✓ User updated in service layer');
  
  // 3. Verify update in HBase
  console.log(`\n3. Verifying update in HBase...`);
  const usersTable = tables.users;
  const row = usersTable.row(testUser.id);
  const [data] = await row.get();
  
  if (!data) {
    console.error('✗ FAILED: User not found in HBase!');
    return false;
  }
  
  const parseRowData = (rowData) => {
    const data = {};
    Object.keys(rowData).forEach(family => {
      Object.keys(rowData[family]).forEach(column => {
        const value = rowData[family][column][0].value;
        data[column] = value;
      });
    });
    return data;
  };
  
  const parsedData = parseRowData(data.data || data);
  console.log('Updated user data in HBase:', JSON.stringify(parsedData, null, 2));
  
  if (parsedData.name !== testName) {
    console.error('✗ FAILED: User name not updated in HBase!');
    console.error(`Expected: ${testName}, Got: ${parsedData.name}`);
    return false;
  }
  
  console.log('✓ User info correctly updated in HBase');
  
  // 4. Restore original name
  console.log(`\n4. Restoring original user name...`);
  await userService.updateUser(testUser.id, {
    name: originalName
  });
  console.log('✓ Original name restored');
  
  return true;
}

async function verifyUserRoleChange() {
  console.log('\n=== Testing User Role Changes ===');
  
  // Find a customer user
  console.log('\n1. Finding a customer user...');
  const users = await userService.getAllUsers(50);
  const customerUser = users.find(u => u.role === 'customer' && u.email !== 'admin@highlands.vn');
  
  if (!customerUser) {
    console.log('No customer user found to test with');
    return true;
  }
  
  console.log(`Found customer: ${customerUser.email} (ID: ${customerUser.id})`);
  
  // 2. Change role to staff
  console.log(`\n2. Changing role from customer to staff...`);
  await userService.updateUserRole(customerUser.id, 'staff');
  console.log('✓ Role updated in service layer');
  
  // 3. Verify in HBase
  console.log(`\n3. Verifying role change in HBase...`);
  const usersTable = tables.users;
  const row = usersTable.row(customerUser.id);
  const [data] = await row.get();
  
  if (!data) {
    console.error('✗ FAILED: User not found in HBase!');
    return false;
  }
  
  const parseRowData = (rowData) => {
    const data = {};
    Object.keys(rowData).forEach(family => {
      Object.keys(rowData[family]).forEach(column => {
        const value = rowData[family][column][0].value;
        data[column] = value;
      });
    });
    return data;
  };
  
  const parsedData = parseRowData(data.data || data);
  
  if (parsedData.role !== 'staff') {
    console.error('✗ FAILED: User role not updated in HBase!');
    console.error(`Expected: staff, Got: ${parsedData.role}`);
    return false;
  }
  
  console.log('✓ User role correctly updated to staff in HBase');
  
  // 4. Restore original role
  console.log(`\n4. Restoring original role (customer)...`);
  await userService.updateUserRole(customerUser.id, 'customer');
  console.log('✓ Original role restored');
  
  return true;
}

async function runAllTests() {
  console.log('╔════════════════════════════════════════════════════════╗');
  console.log('║  Admin Changes Verification Test                      ║');
  console.log('║  Testing if all admin changes are saved to HBase      ║');
  console.log('╚════════════════════════════════════════════════════════╝');
  
  try {
    const productTest = await verifyProductChanges();
    const userTest = await verifyUserChanges();
    const roleTest = await verifyUserRoleChange();
    
    console.log('\n╔════════════════════════════════════════════════════════╗');
    console.log('║  Test Results                                          ║');
    console.log('╠════════════════════════════════════════════════════════╣');
    console.log(`║  Product Changes: ${productTest ? '✓ PASSED' : '✗ FAILED'}                              ║`);
    console.log(`║  User Info Updates: ${userTest ? '✓ PASSED' : '✗ FAILED'}                            ║`);
    console.log(`║  User Role Changes: ${roleTest ? '✓ PASSED' : '✗ FAILED'}                            ║`);
    console.log('╚════════════════════════════════════════════════════════╝');
    
    if (productTest && userTest && roleTest) {
      console.log('\n✓ ALL TESTS PASSED - Admin changes are correctly saved to HBase!');
      process.exit(0);
    } else {
      console.log('\n✗ SOME TESTS FAILED - Check the output above for details');
      process.exit(1);
    }
  } catch (error) {
    console.error('\n✗ ERROR:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

// Run tests
runAllTests();








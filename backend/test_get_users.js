/**
 * Test script to verify getAllUsers returns proper user data
 */

const userService = require('./src/services/userService');

async function testGetUsers() {
  console.log('Testing getAllUsers()...\n');
  
  try {
    const users = await userService.getAllUsers(10);
    
    console.log(`Found ${users.length} users\n`);
    
    users.forEach((user, index) => {
      console.log(`User ${index + 1}:`);
      console.log(`  ID: ${user.id}`);
      console.log(`  Name: ${user.name}`);
      console.log(`  Email: ${user.email}`);
      console.log(`  Phone: ${user.phone}`);
      console.log(`  Role: ${user.role}`);
      console.log(`  Created: ${user.createdAt}`);
      console.log('');
    });
    
    // Check if data is complete
    const missingData = users.filter(u => !u.name || !u.email || !u.phone);
    if (missingData.length > 0) {
      console.log(`⚠️  Warning: ${missingData.length} users have missing data`);
      missingData.forEach(u => {
        console.log(`  - User ${u.id}: name=${u.name}, email=${u.email}, phone=${u.phone}`);
      });
    } else {
      console.log('✓ All users have complete data!');
    }
    
    process.exit(0);
  } catch (error) {
    console.error('Error:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

testGetUsers();








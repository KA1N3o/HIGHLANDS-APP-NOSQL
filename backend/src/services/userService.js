const bcrypt = require('bcrypt');
const { tables } = require('../config/bigtable');
const { parseRowData, createMutations } = require('../utils/helpers');
const User = require('../models/User');

class UserService {
  /**
   * Get user by ID
   */
  async getUserById(userId) {
    const usersTable = tables.users;
    const row = usersTable.row(userId);

    const [data] = await row.get();
    
    if (!data) {
      throw new Error('User not found');
    }

    const userData = parseRowData(data);

    return {
      id: userId,
      email: userData.email,
      name: userData.name,
      phone: userData.phone,
      photoUrl: userData.photoUrl,
      role: userData.role,
      createdAt: userData.createdAt,
      addresses: userData.addresses ? JSON.parse(userData.addresses) : [],
      defaultAddressIndex: userData.defaultAddressIndex ? parseInt(userData.defaultAddressIndex) : 0,
      assignedStoreId: userData.assignedStoreId,
    };
  }

  /**
   * Update user profile
   */
  async updateUser(userId, updates) {
    const usersTable = tables.users;
    const row = usersTable.row(userId);

    // Check if user exists
    const [existingData] = await row.get();
    if (!existingData) {
      throw new Error('User not found');
    }

    // Create mutations for allowed fields
    const allowedFields = ['name', 'phone', 'photoUrl', 'addresses', 'defaultAddressIndex'];
    const updateData = {};
    
    for (const field of allowedFields) {
      if (updates[field] !== undefined) {
        if (field === 'addresses') {
          updateData[field] = JSON.stringify(updates[field]);
        } else if (field === 'defaultAddressIndex') {
          updateData[field] = updates[field].toString();
        } else {
          updateData[field] = updates[field];
        }
      }
    }

    const mutations = createMutations('profile', updateData);
    await row.save(mutations);

    // Return updated user
    return this.getUserById(userId);
  }

  /**
   * Add address to user
   */
  async addAddress(userId, address) {
    const user = await this.getUserById(userId);
    const addresses = user.addresses || [];
    addresses.push(address);
    
    return this.updateUser(userId, { addresses });
  }

  /**
   * Update address
   */
  async updateAddress(userId, addressIndex, address) {
    const user = await this.getUserById(userId);
    const addresses = user.addresses || [];
    
    if (addressIndex < 0 || addressIndex >= addresses.length) {
      throw new Error('Invalid address index');
    }
    
    addresses[addressIndex] = address;
    return this.updateUser(userId, { addresses });
  }

  /**
   * Delete address
   */
  async deleteAddress(userId, addressIndex) {
    const user = await this.getUserById(userId);
    const addresses = user.addresses || [];
    
    if (addressIndex < 0 || addressIndex >= addresses.length) {
      throw new Error('Invalid address index');
    }
    
    addresses.splice(addressIndex, 1);
    
    // Update default address index if necessary
    let defaultAddressIndex = user.defaultAddressIndex;
    if (defaultAddressIndex >= addresses.length) {
      defaultAddressIndex = Math.max(0, addresses.length - 1);
    }
    
    return this.updateUser(userId, { addresses, defaultAddressIndex });
  }

  /**
   * Set default address
   */
  async setDefaultAddress(userId, addressIndex) {
    const user = await this.getUserById(userId);
    const addresses = user.addresses || [];
    
    if (addressIndex < 0 || addressIndex >= addresses.length) {
      throw new Error('Invalid address index');
    }
    
    return this.updateUser(userId, { defaultAddressIndex: addressIndex });
  }

  /**
   * Get order history
   */
  async getOrderHistory(userId, limit = 50) {
    const ordersByUserTable = tables.ordersByUser;
    
    // Scan orders for this user
    const [rows] = await ordersByUserTable.getRows({
      prefix: `${userId}#order#`,
      limit,
    });

    return rows.map(row => {
      const orderData = parseRowData(row);
      const items = [];
      
      // Parse items
      Object.keys(orderData).forEach(key => {
        if (key.startsWith('item_')) {
          items.push(JSON.parse(orderData[key]));
        }
      });

      return {
        id: row.id,
        userId: orderData.userId,
        storeId: orderData.storeId,
        items,
        total: parseFloat(orderData.total),
        status: orderData.status,
        paymentMethod: orderData.paymentMethod,
        paymentStatus: orderData.paymentStatus,
        orderTime: orderData.orderTime,
        completedTime: orderData.completedTime,
      };
    });
  }

  /**
   * Get all users (admin only)
   */
  async getAllUsers(limit = 100) {
    const usersTable = tables.users;
    
    const [rows] = await usersTable.getRows({ limit });

    return rows.map((row) => {
      // Parse row data - data is in row.data for HBase
      const userData = parseRowData(row.data || row);
      return {
        id: row.id,
        email: userData.email || '',
        name: userData.name || '',
        phone: userData.phone || '',
        role: userData.role || 'customer',
        createdAt: userData.createdAt || new Date().toISOString(),
        assignedStoreId: userData.assignedStoreId,
      };
    });
  }

  /**
   * Update user role (admin only)
   */
  async updateUserRole(userId, role, assignedStoreId = null) {
    const usersTable = tables.users;
    const row = usersTable.row(userId);

    // Check if user exists
    const [existingData] = await row.get();
    if (!existingData) {
      throw new Error('User not found');
    }

    const updateData = { role };
    
    // Always update assignedStoreId when changing role
    // Store empty string for non-staff roles or when not assigned
    if (role === 'staff' && assignedStoreId) {
      updateData.assignedStoreId = assignedStoreId;
    } else {
      // Clear assignedStoreId for non-staff roles or when not provided
      updateData.assignedStoreId = '';
    }

    const mutations = createMutations('profile', updateData);
    await row.save(mutations);

    return this.getUserById(userId);
  }

  /**
   * Change user password
   */
  async changePassword(userId, currentPassword, newPassword) {
    const usersTable = tables.users;
    const row = usersTable.row(userId);

    // Check if user exists and get current password hash
    const [existingData] = await row.get();
    if (!existingData) {
      throw new Error('User not found');
    }

    const userData = parseRowData(existingData);

    // Verify current password
    const isValidPassword = await bcrypt.compare(currentPassword, userData.passwordHash || '');
    if (!isValidPassword) {
      throw new Error('Current password is incorrect');
    }

    // Hash new password
    const salt = await bcrypt.genSalt(10);
    const newPasswordHash = await bcrypt.hash(newPassword, salt);

    // Update password in database
    const authMutations = createMutations('auth', {
      passwordHash: newPasswordHash,
      salt: salt,
      passwordChangedAt: new Date().toISOString(),
    });

    await row.save(authMutations);

    return { success: true, message: 'Password changed successfully' };
  }

  /**
   * Delete user (admin only)
   */
  async deleteUser(userId) {
    const usersTable = tables.users;
    const row = usersTable.row(userId);

    // Check if user exists
    const [existingData] = await row.get();
    if (!existingData) {
      throw new Error('User not found');
    }

    const userData = parseRowData(existingData);

    // Prevent deleting admin users
    if (userData.role === 'admin') {
      throw new Error('Cannot delete admin users');
    }

    // Delete the user
    await row.delete();

    return { success: true, message: 'User deleted successfully' };
  }
}

module.exports = new UserService();


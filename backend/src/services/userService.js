const { tables } = require('../config/bigtable');
const { parseRowData, createMutations } = require('../utils/helpers');

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
    const allowedFields = ['name', 'phone', 'photoUrl'];
    const updateData = {};
    
    for (const field of allowedFields) {
      if (updates[field] !== undefined) {
        updateData[field] = updates[field];
      }
    }

    const mutations = createMutations('profile', updateData);
    await row.save(mutations);

    // Return updated user
    return this.getUserById(userId);
  }

  /**
   * Get all users (admin only)
   */
  async getAllUsers(limit = 100) {
    const usersTable = tables.users;
    
    const [rows] = await usersTable.getRows({ limit });

    return rows.map((row) => {
      const userData = parseRowData(row);
      return {
        id: row.id,
        email: userData.email,
        name: userData.name,
        phone: userData.phone,
        role: userData.role,
        createdAt: userData.createdAt,
      };
    });
  }
}

module.exports = new UserService();


const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { tables } = require('../config/bigtable');
const { generateId, createMutations, parseRowData } = require('../utils/helpers');
const config = require('../config');

class AuthService {
  /**
   * Register a new user
   */
  async register(email, password, name, phone) {
    const usersTable = tables.users;

    // Check if user already exists
    const existingUsers = await usersTable.getRows({
      filter: {
        column: {
          cellLimit: 1,
          family: 'profile',
        },
      },
    });

    const [rows] = existingUsers;
    const userExists = rows.some((row) => {
      const data = parseRowData(row.data || row);
      return data.email === email;
    });

    if (userExists) {
      throw new Error('User with this email already exists');
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Generate user ID
    const userId = generateId('user#');
    const createdAt = new Date().toISOString();

    // Create user row
    const profileMutations = createMutations('profile', {
      email: email || '',
      name: name || '',
      phone: phone || '',
      role: email === 'admin@highlands.vn' ? 'admin' : 'customer',
      createdAt: createdAt || '',
    });

    const authMutations = createMutations('auth', {
      passwordHash: passwordHash || '',
      salt: salt || '',
    });

    const row = usersTable.row(userId);
    await row.save([...profileMutations, ...authMutations]);

    // Generate JWT token
    const userRole = email === 'admin@highlands.vn' ? 'admin' : 'customer';
    const token = this.generateToken(userId, email, userRole);

    return {
      user: {
        id: userId || '',
        email: email || '',
        name: name || '',
        phone: phone || '',
        role: userRole || 'customer',
        createdAt: createdAt || new Date().toISOString(),
      },
      token: token || '',
    };
  }

  /**
   * Login user
   */
  async login(email, password) {
    const usersTable = tables.users;

    // Find user by email
    const [rows] = await usersTable.getRows();
    
    let userRow = null;
    let userData = null;

    for (const row of rows) {
      const data = parseRowData(row.data || row);
      if (data.email === email) {
        userRow = row;
        userData = data;
        break;
      }
    }

    if (!userRow || !userData) {
      throw new Error('Invalid email or password');
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(password, userData.passwordHash || '');
    
    if (!isValidPassword) {
      throw new Error('Invalid email or password');
    }

    // Update last login
    const row = usersTable.row(userRow.id);
    const lastLoginMutation = createMutations('auth', {
      lastLogin: new Date().toISOString(),
    });
    await row.save(lastLoginMutation);

    // Generate JWT token
    const token = this.generateToken(userRow.id, userData.email, userData.role);

    return {
      user: {
        id: userRow.id || '',
        email: userData.email || '',
        name: userData.name || '',
        phone: userData.phone || '',
        role: userData.role || 'customer',
        photoUrl: userData.photoUrl || null,
        createdAt: userData.createdAt || new Date().toISOString(),
      },
      token: token || '',
    };
  }

  /**
   * Generate JWT token
   */
  generateToken(userId, email, role) {
    return jwt.sign(
      { 
        userId: userId || '',
        email: email || '',
        role: role || 'customer'
      },
      config.jwtSecret,
      { expiresIn: config.jwtExpiresIn }
    );
  }

  /**
   * Verify JWT token
   */
  verifyToken(token) {
    try {
      return jwt.verify(token, config.jwtSecret);
    } catch (error) {
      throw new Error('Invalid token');
    }
  }
}

module.exports = new AuthService();
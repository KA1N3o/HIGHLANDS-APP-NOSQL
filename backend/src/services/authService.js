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
    const startTime = Date.now();
    const usersTable = tables.users;

    // Find user by email (limit scan to improve performance)
    const [rows] = await usersTable.getRows({ limit: 1000 });
    console.log(`Login: Scanned ${rows.length} users in ${Date.now() - startTime}ms`);
    
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
    
    console.log(`Login: Found user in ${Date.now() - startTime}ms`);

    // Verify password
    const isValidPassword = await bcrypt.compare(password, userData.passwordHash || '');
    
    if (!isValidPassword) {
      throw new Error('Invalid email or password');
    }

    // Auto-fix admin role for admin email
    let userRole = userData.role || 'customer';
    if (email === 'admin@highlands.vn' && userRole !== 'admin') {
      userRole = 'admin';
      // Update role in database
      const roleMutation = createMutations('profile', { role: 'admin' });
      const row = usersTable.row(userRow.id);
      await row.save(roleMutation);
    }

    // Update last login
    const row = usersTable.row(userRow.id);
    const lastLoginMutation = createMutations('auth', {
      lastLogin: new Date().toISOString(),
    });
    await row.save(lastLoginMutation);

    // Generate JWT token
    const token = this.generateToken(userRow.id, userData.email, userRole);

    const result = {
      user: {
        id: userRow.id || '',
        email: userData.email || '',
        name: userData.name || '',
        phone: userData.phone || '',
        role: userRole || 'customer',
        photoUrl: userData.photoUrl || null,
        createdAt: userData.createdAt || new Date().toISOString(),
      },
      token: token || '',
    };

    console.log(`Login: Total time ${Date.now() - startTime}ms`);
    return result;
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
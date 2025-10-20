const jwt = require('jsonwebtoken');
const config = require('../config');
const { errorResponse } = require('../utils/helpers');

/**
 * Middleware to verify JWT token
 */
const authMiddleware = async (req, res, next) => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json(
        errorResponse('No token provided', 401)
      );
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix

    // Verify token
    const decoded = jwt.verify(token, config.jwtSecret);
    
    // Add user info to request
    req.user = {
      userId: decoded.userId,
      email: decoded.email,
      role: decoded.role,
    };

    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json(
        errorResponse('Invalid token', 401)
      );
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json(
        errorResponse('Token expired', 401)
      );
    }

    return res.status(500).json(
      errorResponse('Authentication error', 500)
    );
  }
};

/**
 * Middleware to check if user has admin role
 */
const adminMiddleware = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json(
      errorResponse('Authentication required', 401)
    );
  }

  if (req.user.role !== 'admin') {
    return res.status(403).json(
      errorResponse('Admin access required', 403)
    );
  }

  next();
};

/**
 * Middleware to check if user has shipper role
 */
const shipperMiddleware = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json(
      errorResponse('Authentication required', 401)
    );
  }

  if (req.user.role !== 'shipper' && req.user.role !== 'admin') {
    return res.status(403).json(
      errorResponse('Shipper access required', 403)
    );
  }

  next();
};

/**
 * Middleware to check if user has staff or admin role
 */
const staffMiddleware = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json(
      errorResponse('Authentication required', 401)
    );
  }

  if (!['staff', 'admin'].includes(req.user.role)) {
    return res.status(403).json(
      errorResponse('Staff access required', 403)
    );
  }

  next();
};

/**
 * Middleware to check if user has specific roles
 */
const roleMiddleware = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json(
        errorResponse('Authentication required', 401)
      );
    }

    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json(
        errorResponse('Insufficient permissions', 403)
      );
    }

    next();
  };
};

module.exports = {
  authMiddleware,
  adminMiddleware,
  shipperMiddleware,
  staffMiddleware,
  roleMiddleware,
};


const { errorResponse } = require('../utils/helpers');

/**
 * Global error handler middleware
 */
const errorHandler = (err, req, res, next) => {
  console.error('Error:', err);

  // Handle validation errors
  if (err.name === 'ValidationError') {
    return res.status(400).json(
      errorResponse('Validation error', 400, err.errors)
    );
  }

  // Handle Bigtable errors
  if (err.code === 5) { // NOT_FOUND
    return res.status(404).json(
      errorResponse('Resource not found', 404)
    );
  }

  if (err.code === 6) { // ALREADY_EXISTS
    return res.status(409).json(
      errorResponse('Resource already exists', 409)
    );
  }

  // Default error
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal server error';

  res.status(statusCode).json(
    errorResponse(message, statusCode)
  );
};

/**
 * 404 handler
 */
const notFoundHandler = (req, res) => {
  res.status(404).json(
    errorResponse('Route not found', 404)
  );
};

module.exports = {
  errorHandler,
  notFoundHandler,
};


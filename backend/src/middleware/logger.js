/**
 * Request Logger Middleware
 * Logs all incoming requests with method, path, and response time
 */
const requestLogger = (req, res, next) => {
  const startTime = Date.now();
  const { method, originalUrl, ip } = req;

  // Log request
  console.log(`📥 [${new Date().toISOString()}] ${method} ${originalUrl} - IP: ${ip}`);

  // Capture response
  res.on('finish', () => {
    const duration = Date.now() - startTime;
    const { statusCode } = res;
    
    const emoji = statusCode >= 500 ? '❌' : statusCode >= 400 ? '⚠️' : '✅';
    
    console.log(
      `${emoji} [${new Date().toISOString()}] ${method} ${originalUrl} - Status: ${statusCode} - ${duration}ms`
    );
  });

  next();
};

/**
 * Error Logger Middleware
 * Logs errors with stack trace
 */
const errorLogger = (error, req, res, next) => {
  console.error('🔴 Error occurred:');
  console.error('Time:', new Date().toISOString());
  console.error('Method:', req.method);
  console.error('URL:', req.originalUrl);
  console.error('Error:', error.message);
  console.error('Stack:', error.stack);
  
  next(error);
};

/**
 * Performance Monitor
 * Logs slow requests (> 1000ms)
 */
const performanceMonitor = (req, res, next) => {
  const startTime = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - startTime;
    
    if (duration > 1000) {
      console.warn(
        `⏱️ SLOW REQUEST: ${req.method} ${req.originalUrl} took ${duration}ms`
      );
    }
  });

  next();
};

module.exports = {
  requestLogger,
  errorLogger,
  performanceMonitor,
};





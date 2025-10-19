require('dotenv').config();

module.exports = {
  port: process.env.PORT || 8080,
  nodeEnv: process.env.NODE_ENV || 'development',
  gcpProjectId: process.env.GCP_PROJECT_ID,
  bigtableInstanceId: process.env.BIGTABLE_INSTANCE_ID,
  bigtableClusterId: process.env.BIGTABLE_CLUSTER_ID,
  jwtSecret: process.env.JWT_SECRET || 'default-secret-change-in-production',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '30d',
  allowedOrigins: (process.env.ALLOWED_ORIGINS || '*').split(','),
};


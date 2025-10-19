# Highlands Coffee - Google Bigtable Backend

This directory contains all the necessary scripts and documentation for setting up and managing the Google Bigtable backend for the Highlands Coffee ordering application.

## Prerequisites

1. **Google Cloud Project**: You need an active GCP project
2. **gcloud CLI**: Install from https://cloud.google.com/sdk/docs/install
3. **cbt tool**: Will be installed automatically by setup script
4. **Billing enabled**: Bigtable requires billing to be enabled

## Files

- `schema.md` - Detailed database schema documentation
- `setup.sh` - Initial setup script for creating instance and tables
- `seed_data.sh` - Script to populate sample data
- `queries.sh` - Common query examples and interactive query tool

## Quick Start

### 1. Configure Your Project

Edit `setup.sh` and update the following variables:

```bash
PROJECT_ID="your-gcp-project-id"  # Your GCP project ID
INSTANCE_ID="highlands-coffee"     # Keep as is or customize
CLUSTER_ID="highlands-coffee-cluster"
ZONE="asia-southeast1-a"           # Change to your preferred zone
```

### 2. Run Setup

Make scripts executable and run setup:

```bash
chmod +x *.sh
./setup.sh
```

This will:
- Create Bigtable instance and cluster
- Create all required tables
- Set up column families and policies
- Configure the cbt tool

### 3. Seed Sample Data

```bash
./seed_data.sh
```

This will populate:
- 8 sample products
- 5 sample stores
- 2 test users

### 4. Test Queries

```bash
./queries.sh
```

This provides an interactive menu to run common queries.

## Cost Estimation

Bigtable pricing is based on:
- **Nodes**: ~$0.65/hour per node (3 nodes = ~$1,400/month)
- **Storage**: $0.17/GB per month
- **Network egress**: Varies by usage

**Development recommendation**: 
- Start with 1 node for development (~$470/month)
- Use Bigtable Emulator for local development (free)

### Using Bigtable Emulator (Recommended for Development)

```bash
# Install emulator
gcloud components install cbt bigtable

# Start emulator
gcloud beta emulators bigtable start

# In another terminal, configure cbt
$(gcloud beta emulators bigtable env-init)

# Run setup against emulator
./setup.sh
```

## Integration with Flutter App

### Update API Service

In `lib/services/api_service.dart`, update the base URL:

```dart
// For production
static const String baseUrl = 'https://your-api-gateway.com/api';

// For development with Cloud Run
static const String baseUrl = 'https://your-cloud-run-url.run.app/api';
```

### Backend API Server

You'll need to create a backend API server that:
1. Connects to Bigtable using the Cloud Bigtable Client Library
2. Provides REST endpoints for the Flutter app
3. Handles authentication and authorization

**Recommended stack**:
- Node.js with Express
- Python with Flask/FastAPI
- Go with Gin

**Example deployment**: Deploy to Cloud Run for auto-scaling

## Schema Overview

### Tables

1. **users** - User accounts and authentication
2. **products** - Product catalog
3. **stores** - Store locations
4. **orders** - Customer orders
5. **orders_by_user** - Secondary index for user orders
6. **sessions** - Authentication sessions

See `schema.md` for detailed documentation.

## Common Operations

### View all tables
```bash
cbt ls
```

### Read table data
```bash
cbt read products
cbt read stores
cbt read users prefix=user#test001
```

### Add new product
```bash
cbt set products product#p999 \
  info:name="New Product" \
  info:price="45000" \
  info:category="coffee"
```

### Update order status
```bash
cbt set orders order#12345#ord001 \
  info:status="completed"
```

### Delete row
```bash
cbt deleterow orders order#12345#ord001
```

## Monitoring

### View instance metrics
```bash
gcloud bigtable instances describe highlands-coffee
```

### Check cluster CPU usage
```bash
gcloud bigtable clusters describe highlands-coffee-cluster \
  --instance=highlands-coffee
```

### View operations
Access Cloud Console: https://console.cloud.google.com/bigtable/instances

## Backup and Recovery

### Create backup
```bash
gcloud bigtable backups create backup-$(date +%Y%m%d) \
  --instance=highlands-coffee \
  --cluster=highlands-coffee-cluster \
  --table=orders \
  --retention-period=30d
```

### Restore from backup
```bash
gcloud bigtable backups restore backup-20240115 \
  --destination=orders-restored \
  --destination-instance=highlands-coffee
```

## Security Best Practices

1. **Use IAM roles** - Limit access with service accounts
2. **Enable audit logs** - Track all database access
3. **Encrypt data** - Use customer-managed encryption keys (CMEK)
4. **VPC Service Controls** - Restrict network access
5. **Regular backups** - Automate daily backups

## Troubleshooting

### "Permission denied" errors
```bash
gcloud auth application-default login
gcloud auth login
```

### High latency
- Check node count (may need to scale up)
- Review row key design for hot spotting
- Check network connectivity

### "Table not found" errors
```bash
cbt ls  # Verify table exists
cbt read <table_name>  # Test read access
```

## Next Steps

1. **Set up backend API server** - Create REST API to interface with Bigtable
2. **Implement authentication** - Add JWT token authentication
3. **Set up CI/CD** - Automate deployments
4. **Add monitoring** - Set up alerts for errors and performance
5. **Load testing** - Test with expected traffic volume

## Resources

- [Bigtable Documentation](https://cloud.google.com/bigtable/docs)
- [Schema Design Best Practices](https://cloud.google.com/bigtable/docs/schema-design)
- [cbt CLI Reference](https://cloud.google.com/bigtable/docs/cbt-reference)
- [Client Libraries](https://cloud.google.com/bigtable/docs/reference/libraries)

## Support

For issues or questions:
1. Check `schema.md` for schema details
2. Review query examples in `queries.sh`
3. Consult GCP documentation
4. Contact your development team

---

**Note**: Remember to update your project ID in all scripts before running!


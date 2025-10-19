# Highlands Coffee - Backend API

Backend API server for Highlands Coffee ordering application using Google Bigtable (NoSQL HBase-based database).

## 🏗️ Architecture

- **Framework**: Node.js with Express
- **Database**: Google Cloud Bigtable (NoSQL)
- **Authentication**: JWT (JSON Web Tokens)
- **Deployment**: Google Cloud Run
- **Language**: JavaScript (ES6+)

## 📋 Prerequisites

1. **Node.js** >= 18.0.0
2. **Google Cloud Project** with billing enabled
3. **Google Cloud SDK** (gcloud CLI)
4. **Bigtable Instance** (see `../bigtable/README.md` for setup)

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment

Copy the example environment file and update with your values:

```bash
cp env.example .env
```

Edit `.env`:

```env
PORT=8080
NODE_ENV=development

GCP_PROJECT_ID=your-gcp-project-id
BIGTABLE_INSTANCE_ID=highlands-coffee
BIGTABLE_CLUSTER_ID=highlands-coffee-cluster

JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=30d

ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

### 3. Set Up Google Cloud Authentication

```bash
# Login to Google Cloud
gcloud auth login

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Set application default credentials
gcloud auth application-default login
```

Alternatively, use a service account key:

```bash
# Download service account key from Google Cloud Console
# Then set the environment variable
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
```

### 4. Set Up Bigtable

Follow the instructions in `../bigtable/README.md` to:
- Create Bigtable instance
- Create tables and seed data

```bash
cd ../bigtable
chmod +x *.sh
./setup.sh
./seed_data.sh
```

### 5. Run Development Server

```bash
npm run dev
```

The API will be available at `http://localhost:8080`

## 📚 API Documentation

### Base URL

- Development: `http://localhost:8080`
- Production: `https://your-cloud-run-url.run.app`

### Authentication

Most endpoints require JWT authentication. Include the token in the Authorization header:

```
Authorization: Bearer YOUR_JWT_TOKEN
```

### Endpoints

#### Authentication

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/auth/register` | Register new user | Public |
| POST | `/api/auth/login` | Login user | Public |

**Register Example:**
```json
POST /api/auth/register
{
  "email": "user@example.com",
  "password": "password123",
  "name": "Nguyen Van A",
  "phone": "0901234567"
}
```

**Login Example:**
```json
POST /api/auth/login
{
  "email": "user@example.com",
  "password": "password123"
}
```

#### Users

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/users/:userId` | Get user by ID | Private |
| PUT | `/api/users/:userId` | Update user profile | Private |
| GET | `/api/users` | Get all users | Admin |

#### Products

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/products` | Get all products | Private |
| GET | `/api/products?category=coffee` | Get products by category | Private |
| GET | `/api/products/:productId` | Get product by ID | Private |

#### Stores

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/stores` | Get all stores | Private |
| GET | `/api/stores?lat=10.7756&lon=106.7019` | Get nearby stores | Private |
| GET | `/api/stores/:storeId` | Get store by ID | Private |

#### Orders

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/orders` | Create new order | Private |
| GET | `/api/orders/user/:userId` | Get user's orders | Private |
| GET | `/api/orders/:orderId` | Get order by ID | Private |
| PATCH | `/api/orders/:orderId/status` | Update order status | Admin |
| GET | `/api/orders` | Get all orders | Admin |

**Create Order Example:**
```json
POST /api/orders
{
  "storeId": "store#s001",
  "items": [
    {
      "productId": "product#p001",
      "quantity": 2,
      "size": "Medium",
      "options": [
        {
          "name": "Đường",
          "choice": "Vừa"
        }
      ]
    }
  ],
  "paymentMethod": "card",
  "notes": "Không đá"
}
```

#### Payments

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/payments` | Process payment | Private |
| GET | `/api/payments/:orderId` | Get payment status | Private |

### Response Format

**Success Response:**
```json
{
  "success": true,
  "message": "Success message",
  "data": { ... }
}
```

**Error Response:**
```json
{
  "success": false,
  "error": {
    "message": "Error message",
    "statusCode": 400,
    "errors": [...]
  }
}
```

## 🚢 Deployment

### Deploy to Google Cloud Run

#### Method 1: Using Deploy Script

```bash
# Make script executable
chmod +x deploy.sh

# Set your project ID
export GCP_PROJECT_ID=your-project-id

# Run deployment
./deploy.sh
```

#### Method 2: Manual Deployment

```bash
# Set project
gcloud config set project YOUR_PROJECT_ID

# Build and deploy
gcloud run deploy highlands-coffee-api \
  --source . \
  --region=asia-southeast1 \
  --platform=managed \
  --allow-unauthenticated \
  --set-env-vars="GCP_PROJECT_ID=YOUR_PROJECT_ID,BIGTABLE_INSTANCE_ID=highlands-coffee,NODE_ENV=production"
```

#### Method 3: Using Cloud Build

```bash
# Submit build
gcloud builds submit --config=cloudbuild.yaml
```

### Set Secrets

For production, use Google Secret Manager for sensitive data:

```bash
# Create JWT secret
echo -n "your-jwt-secret" | gcloud secrets create jwt-secret --data-file=-

# Update Cloud Run to use secret
gcloud run services update highlands-coffee-api \
  --region=asia-southeast1 \
  --set-secrets=JWT_SECRET=jwt-secret:latest
```

## 🛠️ Development

### Project Structure

```
backend/
├── src/
│   ├── config/          # Configuration files
│   │   ├── index.js     # Main config
│   │   └── bigtable.js  # Bigtable connection
│   ├── middleware/      # Express middleware
│   │   ├── auth.js      # Authentication middleware
│   │   ├── errorHandler.js
│   │   └── validator.js
│   ├── models/          # Data models (future use)
│   ├── routes/          # API routes
│   │   ├── auth.js
│   │   ├── users.js
│   │   ├── products.js
│   │   ├── stores.js
│   │   ├── orders.js
│   │   └── payments.js
│   ├── services/        # Business logic
│   │   ├── authService.js
│   │   ├── userService.js
│   │   ├── productService.js
│   │   ├── storeService.js
│   │   └── orderService.js
│   ├── utils/           # Helper functions
│   │   └── helpers.js
│   └── server.js        # Express app entry point
├── .dockerignore
├── .gitignore
├── cloudbuild.yaml     # Cloud Build config
├── deploy.sh           # Deployment script
├── Dockerfile          # Docker container config
├── env.example         # Example environment variables
├── package.json        # Dependencies
└── README.md
```

### Running Tests

```bash
npm test
```

### Linting

```bash
npm run lint
```

## 🔐 Security

### Authentication Flow

1. User registers/logs in via `/api/auth/register` or `/api/auth/login`
2. Server returns JWT token
3. Client includes token in Authorization header for protected routes
4. Server verifies token using `authMiddleware`

### Role-Based Access Control

- **customer**: Can view products, stores, create orders, view own orders
- **staff**: Can update order status
- **admin**: Full access to all endpoints

### Best Practices

- Never commit `.env` files
- Use Google Secret Manager for production secrets
- Enable Cloud Armor for DDoS protection
- Use VPC Service Controls to restrict Bigtable access
- Regularly rotate JWT secrets
- Implement rate limiting (future enhancement)

## 📊 Monitoring

### View Logs

```bash
# Cloud Run logs
gcloud run services logs read highlands-coffee-api \
  --region=asia-southeast1 \
  --limit=50

# Follow logs in real-time
gcloud run services logs tail highlands-coffee-api \
  --region=asia-southeast1
```

### Metrics

Monitor in Google Cloud Console:
- Request count
- Response time
- Error rate
- CPU/Memory usage

## 🐛 Troubleshooting

### Common Issues

**1. "Permission denied" errors**
```bash
gcloud auth application-default login
```

**2. "Table not found" errors**
- Verify Bigtable instance is created
- Run setup script: `cd ../bigtable && ./setup.sh`

**3. "Invalid token" errors**
- Check JWT_SECRET is set correctly
- Ensure token hasn't expired

**4. CORS errors**
- Update ALLOWED_ORIGINS in `.env`
- Check CORS configuration in `server.js`

## 📝 Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| PORT | Server port | No | 8080 |
| NODE_ENV | Environment | No | development |
| GCP_PROJECT_ID | Google Cloud project ID | Yes | - |
| BIGTABLE_INSTANCE_ID | Bigtable instance ID | Yes | highlands-coffee |
| BIGTABLE_CLUSTER_ID | Bigtable cluster ID | No | highlands-coffee-cluster |
| JWT_SECRET | Secret for signing JWT | Yes | - |
| JWT_EXPIRES_IN | Token expiration time | No | 30d |
| ALLOWED_ORIGINS | CORS allowed origins | No | * |
| GOOGLE_APPLICATION_CREDENTIALS | Path to service account key | No | - |

## 🔄 Update Flutter App

After deploying the backend, update the Flutter app's API endpoint:

```dart
// lib/services/api_service.dart
static const String baseUrl = 'https://your-cloud-run-url.run.app/api';
```

## 📚 Resources

- [Google Bigtable Documentation](https://cloud.google.com/bigtable/docs)
- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Express.js Documentation](https://expressjs.com/)
- [JWT Authentication](https://jwt.io/)

## 🤝 Contributing

1. Follow the existing code style
2. Write tests for new features
3. Update documentation
4. Submit pull request

## 📄 License

Private - For Highlands Coffee internal use only

---

**Need help?** Check the main project README or contact the development team.


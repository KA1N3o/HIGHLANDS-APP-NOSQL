# 🗄️ Backend Setup Guide - NoSQL (HBase/Bigtable)

Hướng dẫn chi tiết để setup backend sử dụng Google Cloud Bigtable (NoSQL HBase-based database).

## 📊 Kiến trúc Database

```
┌─────────────────┐
│  Flutter App    │
│   (Mobile)      │
└────────┬────────┘
         │ HTTP/REST
         ▼
┌─────────────────┐
│   Backend API   │
│   (Node.js)     │
│  Cloud Run      │
└────────┬────────┘
         │ gRPC
         ▼
┌─────────────────┐
│ Google Bigtable │
│   (NoSQL DB)    │
│    HBase API    │
└─────────────────┘
```

## 🎯 Tổng quan

Dự án đã được thiết kế **SẴN** để sử dụng **NoSQL database (Google Cloud Bigtable)**:

- ✅ Schema NoSQL đã được thiết kế (xem `bigtable/schema.md`)
- ✅ Backend API Node.js đã được implement (thư mục `backend/`)
- ✅ Scripts setup tự động cho Bigtable (thư mục `bigtable/`)
- ✅ Flutter app đã tích hợp sẵn API service

## 🚀 Quick Start

### Prerequisites

1. **Google Cloud Project** với billing enabled
2. **Node.js** >= 18.0.0
3. **Google Cloud SDK** (gcloud CLI)

### Bước 1: Setup Google Cloud Bigtable

```bash
cd bigtable

# Chỉnh sửa PROJECT_ID trong setup.sh
nano setup.sh  # Hoặc dùng editor yêu thích

# Chạy setup
chmod +x *.sh
./setup.sh

# Seed data mẫu
./seed_data.sh
```

**Kết quả:** Tạo Bigtable instance với 6 tables:
- `users` - Thông tin user
- `products` - Danh mục sản phẩm
- `stores` - Cửa hàng
- `orders` - Đơn hàng
- `orders_by_user` - Index cho user orders
- `sessions` - Authentication sessions

### Bước 2: Setup Backend API

```bash
cd backend

# Install dependencies
npm install

# Configure environment
cp env.example .env
nano .env  # Update với thông tin GCP của bạn
```

**Cấu hình `.env`:**
```env
GCP_PROJECT_ID=your-project-id
BIGTABLE_INSTANCE_ID=highlands-coffee
JWT_SECRET=your-secret-key
```

### Bước 3: Chạy Backend (Development)

```bash
npm run dev
```

Backend sẽ chạy tại `http://localhost:8080`

### Bước 4: Deploy lên Cloud Run (Production)

```bash
chmod +x deploy.sh
export GCP_PROJECT_ID=your-project-id
./deploy.sh
```

### Bước 5: Update Flutter App

```dart
// lib/services/api_service.dart
static const String baseUrl = 'https://your-cloud-run-url.run.app/api';
```

## 📋 Database Schema (NoSQL)

### Row Key Design

Bigtable sử dụng **row key** để tối ưu query performance:

```
users:        user#{user_id}
products:     product#{product_id}
stores:       store#{store_id}
orders:       order#{reversed_timestamp}#{order_id}
orders_by_user: user#{user_id}#order#{reversed_timestamp}#{order_id}
sessions:     session#{token}
```

### Column Families

Mỗi table có nhiều column families để tổ chức data:

**Users:**
- `profile:` email, name, phone, role, createdAt
- `auth:` passwordHash, salt, lastLogin

**Products:**
- `info:` name, description, price, category, imageUrl
- `options:` sizes, optionsData (JSON)

**Orders:**
- `info:` userId, storeId, status, orderTime
- `payment:` method, status, total, tax
- `items:` item_0, item_1, ... (JSON)

Xem chi tiết: `bigtable/schema.md`

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/register` - Đăng ký user mới
- `POST /api/auth/login` - Login

### Products
- `GET /api/products` - Lấy tất cả products
- `GET /api/products/:id` - Chi tiết product
- `GET /api/products?category=coffee` - Filter by category

### Stores
- `GET /api/stores` - Lấy tất cả stores
- `GET /api/stores/:id` - Chi tiết store
- `GET /api/stores?lat=10.77&lon=106.70` - Tìm stores gần

### Orders
- `POST /api/orders` - Tạo order mới
- `GET /api/orders/user/:userId` - Orders của user
- `GET /api/orders/:id` - Chi tiết order
- `PATCH /api/orders/:id/status` - Update status (admin)

### Users
- `GET /api/users/:id` - Thông tin user
- `PUT /api/users/:id` - Update profile

Xem chi tiết: `backend/README.md`

## 💡 NoSQL vs SQL

### Tại sao chọn NoSQL (Bigtable)?

**Ưu điểm:**
- ⚡ **Performance cao** - Millisecond latency cho read/write
- 📈 **Scalability** - Tự động scale với data lớn
- 🌐 **High availability** - Không downtime
- 💪 **Handles big data** - Hàng tỷ rows, petabytes data

**Phù hợp cho:**
- Time-series data (orders sorted by time)
- User activity tracking
- Real-time analytics
- Mobile/IoT applications

### Schema Design Principles

1. **Denormalization** - Store complete data in each row
2. **Row key optimization** - Design for query patterns
3. **No JOINs** - Pre-join data at write time
4. **Time-based ordering** - Use reversed timestamp

## 🧪 Testing

### Test với curl

```bash
# Health check
curl http://localhost:8080/health

# Register
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "123456",
    "name": "Test User",
    "phone": "0901234567"
  }'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "123456"
  }'

# Get products (cần token)
curl http://localhost:8080/api/products \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Test với Postman

Import collection từ `backend/postman_collection.json` (nếu có)

## 🔐 Security

### Authentication Flow

1. User đăng ký/login → nhận JWT token
2. Client lưu token (SharedPreferences)
3. Gửi token trong header cho mọi request
4. Backend verify token → cho phép access

### Best Practices

- ✅ JWT token expires sau 30 ngày
- ✅ Password được hash với bcrypt
- ✅ Role-based access control (customer, staff, admin)
- ✅ CORS protection
- ✅ Input validation với express-validator

## 💰 Chi phí ước tính

### Bigtable Pricing

**Development:**
- 1 node: ~$470/tháng
- Storage: $0.17/GB/tháng
- **Khuyến nghị:** Dùng Bigtable Emulator (miễn phí)

**Production:**
- 3 nodes: ~$1,400/tháng
- Network: ~$0.12/GB

### Cloud Run Pricing

- **Free tier:** 2 triệu requests/tháng
- Sau đó: $0.40/1M requests
- Memory/CPU: ~$0.00001875/second

**Ước tính:** ~$10-50/tháng cho medium traffic

### Total: ~$500-1500/tháng (production)

## 🛠️ Development với Emulator

**FREE** - Chạy Bigtable local:

```bash
# Install emulator
gcloud components install cbt bigtable

# Start emulator
gcloud beta emulators bigtable start

# Trong terminal khác
$(gcloud beta emulators bigtable env-init)

# Run setup against emulator
cd bigtable && ./setup.sh
```

## 📊 Monitoring & Logging

### View Logs

```bash
# Backend logs
npm run dev  # Console logs

# Cloud Run logs
gcloud run services logs tail highlands-coffee-api \
  --region=asia-southeast1
```

### Metrics

- Request count
- Response time
- Error rate
- Database latency

## 🐛 Troubleshooting

### "Permission denied"
```bash
gcloud auth application-default login
```

### "Table not found"
```bash
cd bigtable
./setup.sh
```

### "Connection timeout"
- Check GCP credentials
- Verify Bigtable instance is running
- Check network/firewall

## 📚 Tài liệu tham khảo

- 📖 [Backend API Documentation](backend/README.md)
- 📖 [Bigtable Schema](bigtable/schema.md)
- 📖 [Bigtable Setup Guide](bigtable/README.md)
- 🔗 [Google Bigtable Docs](https://cloud.google.com/bigtable/docs)
- 🔗 [Node.js Bigtable Client](https://googleapis.dev/nodejs/bigtable/latest/)

## ✅ Checklist Setup

- [ ] Tạo GCP project và enable billing
- [ ] Cài đặt gcloud CLI
- [ ] Chạy `bigtable/setup.sh` để tạo tables
- [ ] Chạy `bigtable/seed_data.sh` để seed data
- [ ] Setup backend: `cd backend && npm install`
- [ ] Configure `.env` với GCP credentials
- [ ] Test local: `npm run dev`
- [ ] Deploy production: `./deploy.sh`
- [ ] Update Flutter app với backend URL
- [ ] Test end-to-end flow

## 🎉 Done!

Backend NoSQL (HBase/Bigtable) của bạn đã sẵn sàng! 🚀

**Next steps:**
1. Test các API endpoints
2. Integrate với Flutter app
3. Deploy lên production
4. Monitor performance

---

**Questions?** Check các file README hoặc tạo issue.

Happy coding! ☕



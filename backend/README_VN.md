# Highlands Coffee Backend API

Backend API server cho ứng dụng đặt café Highland online sử dụng Google Cloud Bigtable.

## 🚀 Tính năng

### 1. Quản lý người dùng
- ✅ Đăng ký/Đăng nhập với JWT authentication
- ✅ Quản lý profile và địa chỉ giao hàng
- ✅ Lịch sử đơn hàng
- ✅ Phân quyền: Customer, Staff, Admin, Shipper

### 2. Quản lý sản phẩm
- ✅ CRUD sản phẩm (Admin)
- ✅ Danh sách sản phẩm theo danh mục
- ✅ Tìm kiếm sản phẩm
- ✅ Chi tiết sản phẩm với options (size, đường, đá, etc.)

### 3. Giỏ hàng
- ✅ Thêm/Sửa/Xóa sản phẩm trong giỏ
- ✅ Tính toán tổng tiền tự động
- ✅ Lưu trữ trong Bigtable

### 4. Đặt hàng
- ✅ Tạo đơn hàng từ giỏ hàng
- ✅ Theo dõi trạng thái đơn hàng (Pending → Confirmed → Preparing → Delivering → Completed)
- ✅ Hủy đơn hàng (khi chưa preparing)
- ✅ Áp dụng mã khuyến mãi
- ✅ Tính phí giao hàng và thuế

### 5. Giao hàng
- ✅ Quản lý trạng thái giao hàng
- ✅ Cập nhật vị trí real-time (GPS)
- ✅ Phân công shipper
- ✅ API cho shipper

### 6. Thanh toán
- ✅ COD (Cash on Delivery)
- ✅ Hỗ trợ ví điện tử (MoMo, ZaloPay)
- ✅ Cập nhật trạng thái thanh toán

### 7. Khuyến mãi
- ✅ CRUD mã khuyến mãi (Admin)
- ✅ Validate và áp dụng mã giảm giá
- ✅ Giảm theo % hoặc số tiền cố định
- ✅ Giới hạn số lần sử dụng

### 8. Admin Dashboard
- ✅ Quản lý sản phẩm
- ✅ Quản lý đơn hàng
- ✅ Quản lý người dùng và phân quyền
- ✅ Quản lý khuyến mãi
- ✅ Báo cáo thống kê (doanh thu, đơn hàng)

### 9. Logging & Monitoring
- ✅ Request/Response logging
- ✅ Performance monitoring
- ✅ Error tracking

## 🏗️ Kiến trúc

```
backend/
├── src/
│   ├── config/          # Cấu hình (Bigtable, JWT, etc.)
│   ├── models/          # Data models (User, Product, Order, etc.)
│   ├── services/        # Business logic
│   ├── routes/          # API routes
│   ├── middleware/      # Auth, logging, error handling
│   ├── utils/           # Helper functions
│   └── server.js        # Express server
├── package.json
└── README.md
```

## 📦 Công nghệ sử dụng

- **Framework**: Express.js
- **Database**: Google Cloud Bigtable (HBase-compatible)
- **Authentication**: JWT (JSON Web Tokens)
- **Password Hashing**: bcrypt
- **Validation**: express-validator

## 🛠️ Cài đặt

### Yêu cầu
- Node.js >= 18.0.0
- Google Cloud account với Bigtable enabled
- Service Account key với quyền truy cập Bigtable

### Bước 1: Clone repository
```bash
cd backend
npm install
```

### Bước 2: Cấu hình môi trường
Tạo file `.env`:
```env
PORT=8080
NODE_ENV=development

# Google Cloud
GCP_PROJECT_ID=your-project-id
BIGTABLE_INSTANCE_ID=highlands-coffee
BIGTABLE_CLUSTER_ID=highlands-coffee-cluster
GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account-key.json

# JWT
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=30d

# CORS
ALLOWED_ORIGINS=*
```

### Bước 3: Tạo Bigtable tables
```bash
cd ../bigtable
chmod +x setup.sh
./setup.sh
```

### Bước 4: Khởi chạy server
```bash
npm run dev     # Development với nodemon
npm start       # Production
```

Server sẽ chạy tại: `http://localhost:8080`

## 📚 API Documentation

Xem [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) để biết chi tiết về tất cả endpoints.

### Quick Start

1. **Register**
```bash
POST /api/auth/register
{
  "email": "user@example.com",
  "password": "password123",
  "name": "Nguyen Van A",
  "phone": "0901234567"
}
```

2. **Login**
```bash
POST /api/auth/login
{
  "email": "user@example.com",
  "password": "password123"
}
```

3. **Get Products**
```bash
GET /api/products
Authorization: Bearer <your_token>
```

4. **Create Order**
```bash
POST /api/orders
Authorization: Bearer <your_token>
{
  "storeId": "store#s001",
  "items": [...],
  "paymentMethod": "COD",
  "deliveryAddress": {...}
}
```

## 🧪 Testing

Sử dụng file `test_api.http` với REST Client extension trong VS Code:

1. Cài đặt extension "REST Client"
2. Mở file `test_api.http`
3. Click "Send Request" trên mỗi endpoint

## 🗄️ Database Schema

Xem [../bigtable/schema.md](../bigtable/schema.md) để biết chi tiết về cấu trúc tables.

### Tables chính:
- `users` - Thông tin người dùng
- `products` - Sản phẩm
- `carts` - Giỏ hàng
- `orders` - Đơn hàng
- `orders_by_user` - Index cho user orders
- `deliveries` - Thông tin giao hàng
- `promotions` - Mã khuyến mãi
- `stores` - Cửa hàng
- `sessions` - JWT sessions

## 🔐 Authentication & Authorization

### Roles:
- **customer**: Khách hàng (mặc định)
- **staff**: Nhân viên cửa hàng
- **shipper**: Người giao hàng
- **admin**: Quản trị viên

### Protected Routes:
- `/api/users/*` - Authenticated users
- `/api/admin/*` - Admin only
- `/api/delivery/shipper` - Shipper only

## 🚢 Deployment

### Google Cloud Run
```bash
# Build image
docker build -t gcr.io/YOUR_PROJECT/highlands-api .

# Push to registry
docker push gcr.io/YOUR_PROJECT/highlands-api

# Deploy
gcloud run deploy highlands-api \
  --image gcr.io/YOUR_PROJECT/highlands-api \
  --platform managed \
  --region asia-southeast1 \
  --allow-unauthenticated
```

## 📈 Monitoring

Logs được tự động ghi với format:
```
📥 [timestamp] METHOD /path - IP: xxx.xxx.xxx.xxx
✅ [timestamp] METHOD /path - Status: 200 - 45ms
```

Slow requests (>1000ms) được log với warning:
```
⏱️ SLOW REQUEST: GET /api/orders took 1234ms
```

## 📝 License

MIT License

## 📞 Support

Email: support@highlands.vn





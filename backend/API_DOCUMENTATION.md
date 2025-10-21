# Highlands Coffee API Documentation

## Base URL
```
Development: http://localhost:8080
Production: https://your-domain.com
```

## Authentication
All API endpoints (except registration and login) require authentication using JWT Bearer token.

### Headers
```
Authorization: Bearer <your_jwt_token>
Content-Type: application/json
```

---

## API Endpoints

### 1. Authentication

#### Register
```http
POST /api/auth/register
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "Nguyen Van A",
  "phone": "0901234567"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "user": {
      "id": "user#abc123",
      "email": "user@example.com",
      "name": "Nguyen Van A",
      "phone": "0901234567",
      "role": "customer"
    },
    "token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

#### Login
```http
POST /api/auth/login
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

---

### 2. User Management

#### Get Current User Profile
```http
GET /api/users/me
```

#### Update Profile
```http
PUT /api/users/me
```

**Request Body:**
```json
{
  "name": "New Name",
  "phone": "0909999999",
  "photoUrl": "https://..."
}
```

#### Add Address
```http
POST /api/users/me/addresses
```

**Request Body:**
```json
{
  "name": "Nhà riêng",
  "address": "123 Nguyen Hue, Q1, TP.HCM",
  "lat": "10.7756",
  "lng": "106.7019",
  "phone": "0901234567",
  "isDefault": true
}
```

#### Get Order History
```http
GET /api/users/me/orders?limit=50
```

---

### 3. Products

#### Get All Products
```http
GET /api/products?category=coffee&available=true
```

**Query Parameters:**
- `category` (optional): coffee, tea, smoothie, food, pastry
- `available` (optional): true/false - filter by availability

#### Search Products
```http
GET /api/products/search?q=cafe&available=true
```

#### Get Product Details
```http
GET /api/products/:productId
```

#### Get Categories
```http
GET /api/products/categories
```

---

### 4. Cart

#### Get Cart
```http
GET /api/cart
```

#### Add Item to Cart
```http
POST /api/cart/items
```

**Request Body:**
```json
{
  "productId": "product#p001",
  "quantity": 2,
  "size": "Large",
  "options": {
    "Đường": "Vừa",
    "Đá": "Ít"
  },
  "note": "Không thêm kem"
}
```

#### Update Cart Item
```http
PUT /api/cart/items/:index
```

**Request Body:**
```json
{
  "quantity": 3
}
```

#### Remove Cart Item
```http
DELETE /api/cart/items/:index
```

#### Clear Cart
```http
DELETE /api/cart
```

---

### 5. Orders

#### Create Order
```http
POST /api/orders
```

**Request Body:**
```json
{
  "storeId": "store#s001",
  "items": [
    {
      "productId": "product#p001",
      "quantity": 2,
      "size": "Large",
      "options": {"Đường": "Vừa"}
    }
  ],
  "paymentMethod": "COD",
  "deliveryAddress": {
    "name": "Nhà riêng",
    "address": "123 Nguyen Hue, Q1",
    "lat": "10.7756",
    "lng": "106.7019",
    "phone": "0901234567"
  },
  "promotionCode": "HIGHLAND2024",
  "notes": "Giao trước 5pm"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Order created successfully",
  "data": {
    "id": "ord123",
    "userId": "user#abc123",
    "store": {...},
    "items": [...],
    "subtotal": 100000,
    "tax": 10000,
    "deliveryFee": 15000,
    "discount": 20000,
    "total": 105000,
    "status": "pending",
    "paymentMethod": "COD",
    "paymentStatus": "pending",
    "orderTime": "2024-01-15T14:30:00Z"
  }
}
```

#### Get Order Details
```http
GET /api/orders/:orderId
```

#### Cancel Order
```http
POST /api/orders/:orderId/cancel
```

**Request Body:**
```json
{
  "reason": "Đổi ý không mua nữa"
}
```

---

### 6. Promotions

#### Get Active Promotions
```http
GET /api/promotions
```

#### Validate Promotion Code
```http
POST /api/promotions/validate
```

**Request Body:**
```json
{
  "code": "HIGHLAND2024",
  "orderValue": 100000
}
```

**Response:**
```json
{
  "success": true,
  "message": "Promotion is valid",
  "data": {
    "promotion": {...},
    "discount": 20000
  }
}
```

---

### 7. Delivery (Shipper APIs)

#### Get Shipper Deliveries
```http
GET /api/delivery/shipper?status=delivering
```

**Headers:** Requires shipper role

#### Update Delivery Status
```http
PUT /api/delivery/:deliveryId/status
```

**Request Body:**
```json
{
  "status": "delivering",
  "location": {
    "lat": "10.7756",
    "lng": "106.7019"
  }
}
```

**Status Values:**
- `pending`: Chờ phân công
- `assigned`: Đã phân cho shipper
- `picking_up`: Đang lấy hàng
- `delivering`: Đang giao
- `delivered`: Đã giao
- `failed`: Giao thất bại

#### Update Location
```http
PUT /api/delivery/:deliveryId/location
```

**Request Body:**
```json
{
  "lat": "10.7756",
  "lng": "106.7019"
}
```

#### Get Delivery by Order
```http
GET /api/delivery/order/:orderId
```

---

### 8. Admin APIs

All admin APIs require admin role.

#### Product Management

**Create Product:**
```http
POST /api/admin/products
```

**Update Product:**
```http
PUT /api/admin/products/:productId
```

**Delete Product:**
```http
DELETE /api/admin/products/:productId
```

#### Promotion Management

**Get All Promotions:**
```http
GET /api/admin/promotions
```

**Create Promotion:**
```http
POST /api/admin/promotions
```

**Request Body:**
```json
{
  "code": "NEWYEAR2024",
  "name": "Giảm giá đầu năm",
  "description": "Giảm 20% cho đơn hàng từ 100k",
  "type": "percentage",
  "value": 20,
  "minOrderValue": 100000,
  "maxDiscount": 50000,
  "usageLimit": 100,
  "startDate": "2024-01-01T00:00:00Z",
  "endDate": "2024-12-31T23:59:59Z",
  "isActive": true
}
```

**Update Promotion:**
```http
PUT /api/admin/promotions/:promotionId
```

**Delete Promotion:**
```http
DELETE /api/admin/promotions/:promotionId
```

#### Order Management

**Get All Orders:**
```http
GET /api/admin/orders?limit=100
```

**Update Order Status:**
```http
PUT /api/admin/orders/:orderId/status
```

**Request Body:**
```json
{
  "status": "confirmed"
}
```

**Status Flow:**
1. `pending` - Chờ xác nhận
2. `confirmed` - Đã xác nhận
3. `preparing` - Đang chuẩn bị
4. `delivering` - Đang giao hàng
5. `completed` - Hoàn thành
6. `cancelled` - Đã hủy

#### User Management

**Get All Users:**
```http
GET /api/admin/users?limit=100
```

**Update User Role:**
```http
PUT /api/admin/users/:userId/role
```

**Request Body:**
```json
{
  "role": "shipper"
}
```

**Available Roles:**
- `customer` - Khách hàng
- `staff` - Nhân viên
- `shipper` - Người giao hàng
- `admin` - Quản trị viên

#### Reports

**Get Overview Statistics:**
```http
GET /api/admin/reports/overview?startDate=2024-01-01&endDate=2024-12-31
```

**Response:**
```json
{
  "success": true,
  "data": {
    "period": {
      "startDate": "2024-01-01",
      "endDate": "2024-12-31"
    },
    "statistics": {
      "totalOrders": 1500,
      "completedOrders": 1350,
      "cancelledOrders": 100,
      "pendingOrders": 50,
      "totalRevenue": 150000000,
      "avgOrderValue": 111111
    }
  }
}
```

---

### 9. Stores

#### Get All Stores
```http
GET /api/stores
```

#### Get Store Details
```http
GET /api/stores/:storeId
```

#### Get Nearby Stores
```http
GET /api/stores/nearby?lat=10.7756&lng=106.7019&radius=5
```

---

## Error Responses

All error responses follow this format:

```json
{
  "success": false,
  "message": "Error message",
  "statusCode": 400
}
```

### Common Status Codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

---

## Rate Limiting

- Rate limit: 100 requests per minute per IP
- Exceeded limit returns status 429

---

## Testing

Use the provided `test_api.http` file with REST Client extension in VS Code.

Example:
```http
### Register
POST {{baseUrl}}/api/auth/register
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123",
  "name": "Test User",
  "phone": "0901234567"
}
```

---

## Support

For issues or questions, contact: support@highlands.vn









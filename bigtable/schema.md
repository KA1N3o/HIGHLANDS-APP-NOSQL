# Highlands Coffee - Google Bigtable Schema

## Overview
This document describes the Google Bigtable schema for the Highlands Coffee ordering application.

## Instance Configuration
- **Instance ID**: `highlands-coffee`
- **Cluster ID**: `highlands-coffee-cluster`
- **Location**: `asia-southeast1-a` (Singapore)
- **Storage Type**: SSD

## Tables

### 1. users
Stores user account information.
Stores user account information.

**Row Key Format**: `user#{user_id}`

**Column Families**:
- `profile` (max versions: 1)
  - `email`: User email address
  - `name`: Full name
  - `phone`: Phone number
  - `photoUrl`: Profile photo URL
  - `role`: User role (customer, staff, admin, shipper)
  - `addresses`: JSON array of delivery addresses
  - `defaultAddressIndex`: Index of default address
  - `createdAt`: Account creation timestamp

- `auth` (max versions: 1)
  - `passwordHash`: Hashed password
  - `salt`: Password salt
  - `lastLogin`: Last login timestamp

**Example Row**:
```
Row Key: user#abc123
  profile:email = "user@example.com"
  profile:name = "Nguyen Van A"
  profile:phone = "0901234567"
  profile:role = "customer"
  profile:createdAt = "2024-01-15T10:30:00Z"
  auth:passwordHash = "..."
  auth:salt = "..."
```

---

### 2. products
Stores product catalog information.

**Row Key Format**: `product#{product_id}`

**Column Families**:
- `info` (max versions: 1)
  - `name`: Product name
  - `description`: Product description
  - `price`: Base price
  - `imageUrl`: Product image URL
  - `category`: Product category (coffee, tea, smoothie, food, pastry)
  - `isAvailable`: Availability status (true/false)
  - `preparationTime`: Preparation time in minutes

- `options` (max versions: 1)
  - `sizes`: JSON array of available sizes
  - `optionsData`: JSON array of product options (sugar level, ice level, etc.)

**Example Row**:
```
Row Key: product#p001
  info:name = "Phin Sữa Đá"
  info:description = "Cà phê phin truyền thống Việt Nam"
  info:price = "39000"
  info:category = "coffee"
  info:isAvailable = "true"
  info:preparationTime = "8"
  options:sizes = '["Small","Medium","Large"]'
  options:optionsData = '[{"name":"Đường","choices":["Ít","Vừa","Nhiều"]}]'
```

---

### 3. stores
Stores information about coffee shop locations.

**Row Key Format**: `store#{store_id}`

**Column Families**:
- `info` (max versions: 1)
  - `name`: Store name
  - `address`: Full address
  - `latitude`: Latitude coordinate
  - `longitude`: Longitude coordinate
  - `phone`: Contact phone number
  - `imageUrl`: Store image URL
  - `isOpen`: Current open/close status

- `hours` (max versions: 1)
  - `openTime`: Opening time (HH:MM format)
  - `closeTime`: Closing time (HH:MM format)

**Example Row**:
```
Row Key: store#s001
  info:name = "Highlands Coffee - Nguyễn Huệ"
  info:address = "123 Nguyễn Huệ, Q.1, TP.HCM"
  info:latitude = "10.7756"
  info:longitude = "106.7019"
  info:phone = "0901234567"
  info:isOpen = "true"
  hours:openTime = "07:00"
  hours:closeTime = "22:00"
```

---

### 4. orders
Stores customer orders.

**Row Key Format**: `order#{timestamp_reversed}#{order_id}`
- Using reversed timestamp for efficient time-range queries (most recent first)
- Example: `order#9223370482312345678#abc123`

**Column Families**:
- `info` (max versions: 1)
  - `userId`: Customer user ID
  - `storeId`: Store ID
  - `orderTime`: Order creation timestamp
  - `pickupTime`: Requested pickup time
  - `completedTime`: Order completion timestamp
  - `status`: Order status (pending, confirmed, preparing, ready, completed, cancelled)
  - `notes`: Customer notes

- `payment` (max versions: 1)
  - `method`: Payment method (card, cash, momo, zalopay)
  - `status`: Payment status (pending, paid, failed, refunded)
  - `subtotal`: Subtotal amount
  - `tax`: Tax amount
  - `total`: Total amount

- `items` (max versions: 1)
  - `item_{n}`: JSON representation of each cart item
  - Format: `{"productId":"p001","name":"Phin Sữa Đá","size":"Medium","quantity":2,...}`

**Example Row**:
```
Row Key: order#9223370482312345678#ord001
  info:userId = "user#abc123"
  info:storeId = "store#s001"
  info:orderTime = "2024-01-15T14:30:00Z"
  info:status = "preparing"
  payment:method = "card"
  payment:status = "paid"
  payment:total = "78000"
  items:item_0 = '{"productId":"p001","quantity":2,...}'
  items:item_1 = '{"productId":"p002","quantity":1,...}'
```

**Secondary Index**:
- Table: `orders_by_user`
- Row Key: `user#{user_id}#order#{timestamp_reversed}#{order_id}`
- Use for efficient user order history queries

---

### 5. carts
Stores user shopping cart items.

**Row Key Format**: `user#{user_id}`

**Column Families**:
- `items` (max versions: 1)
  - `item_{n}`: JSON representation of each cart item
  - Format: `{"productId":"p001","productName":"Phin Sữa Đá","price":39000,"quantity":2,"size":"Medium","options":{},"imageUrl":"...","note":""}`

- `meta` (max versions: 1)
  - `updatedAt`: Last update timestamp
  - `totalItems`: Total number of items
  - `totalPrice`: Total price

**Example Row**:
```
Row Key: user#abc123
  items:item_0 = '{"productId":"p001","quantity":2,...}'
  items:item_1 = '{"productId":"p002","quantity":1,...}'
  meta:updatedAt = "2024-01-15T14:30:00Z"
  meta:totalItems = "3"
  meta:totalPrice = "117000"
```

---

### 6. deliveries
Stores delivery information for orders.

**Row Key Format**: `delivery#{delivery_id}`

**Column Families**:
- `info` (max versions: 1)
  - `orderId`: Associated order ID
  - `shipperId`: Shipper user ID
  - `shipperName`: Shipper name
  - `shipperPhone`: Shipper phone
  - `status`: Delivery status (pending, assigned, picking_up, delivering, delivered, failed)
  - `pickupAddress`: JSON - Store/pickup location
  - `deliveryAddress`: JSON - Customer delivery address
  - `currentLocation`: JSON - Current GPS location
  - `estimatedDeliveryTime`: Estimated delivery time
  - `actualDeliveryTime`: Actual delivery time
  - `notes`: Delivery notes
  - `failureReason`: Reason for failed delivery
  - `createdAt`: Delivery creation time
  - `updatedAt`: Last update time

**Example Row**:
```
Row Key: delivery#dlv001
  info:orderId = "ord001"
  info:shipperId = "user#shipper123"
  info:shipperName = "Nguyen Van B"
  info:status = "delivering"
  info:deliveryAddress = '{"name":"...","address":"...","lat":"...","lng":"..."}'
  info:currentLocation = '{"lat":"10.7756","lng":"106.7019","timestamp":"..."}'
```

---

### 7. promotions
Stores promotion/discount codes.

**Row Key Format**: `promo#{promotion_id}`

**Column Families**:
- `info` (max versions: 1)
  - `code`: Promotion code (unique)
  - `name`: Promotion name
  - `description`: Promotion description
  - `type`: Discount type (percentage, fixed_amount, free_shipping)
  - `value`: Discount value
  - `minOrderValue`: Minimum order value required
  - `maxDiscount`: Maximum discount amount (for percentage type)
  - `usageLimit`: Maximum number of uses (null = unlimited)
  - `usageCount`: Current usage count
  - `startDate`: Promotion start date
  - `endDate`: Promotion end date
  - `isActive`: Active status
  - `createdAt`: Creation time
  - `updatedAt`: Last update time

**Example Row**:
```
Row Key: promo#p001
  info:code = "HIGHLAND2024"
  info:name = "Giảm giá đầu năm"
  info:type = "percentage"
  info:value = "20"
  info:minOrderValue = "100000"
  info:maxDiscount = "50000"
  info:usageLimit = "100"
  info:usageCount = "45"
  info:startDate = "2024-01-01T00:00:00Z"
  info:endDate = "2024-12-31T23:59:59Z"
  info:isActive = "true"
```

---

### 8. payments
Stores payment transaction information.

**Row Key Format**: `payment#{payment_id}`

**Column Families**:
- `info` (max versions: 1)
  - `orderId`: Associated order ID
  - `userId`: User ID
  - `amount`: Payment amount
  - `method`: Payment method (COD, card, momo, zalopay)
  - `status`: Payment status (pending, paid, failed, refunded)
  - `transactionId`: External transaction ID (for online payments)
  - `metadata`: JSON - Additional payment metadata
  - `createdAt`: Payment creation time
  - `updatedAt`: Last update time

**Example Row**:
```
Row Key: payment#pay001
  info:orderId = "ord001"
  info:userId = "user#abc123"
  info:amount = "117000"
  info:method = "momo"
  info:status = "paid"
  info:transactionId = "momo_tx_12345"
  info:createdAt = "2024-01-15T14:30:00Z"
```

---

### 9. sessions
Stores user authentication sessions.

**Row Key Format**: `session#{session_token}`

**Column Families**:
- `data` (max versions: 1, TTL: 30 days)
  - `userId`: User ID
  - `createdAt`: Session creation time
  - `expiresAt`: Session expiration time
  - `deviceInfo`: Device information

**Example Row**:
```
Row Key: session#xyz789
  data:userId = "user#abc123"
  data:createdAt = "2024-01-15T10:00:00Z"
  data:expiresAt = "2024-02-14T10:00:00Z"
  data:deviceInfo = "Android 13"
```

---

## Indexing Strategy

### 1. Time-based Queries
Orders use reversed timestamp in row key for efficient recent-first queries:
```
Scan: order#9223370482312345678 to order#0
```

### 2. User Orders
Maintain `orders_by_user` table for user-specific queries:
```
Scan: user#abc123#order# (prefix scan)
```

### 3. Store Orders
For store-specific order management:
- Filter on `info:storeId` during scan
- Consider separate `orders_by_store` table for high-volume stores

---

## Access Patterns

### Common Queries:
1. **Get user by ID**: Direct row key lookup on `users` table
2. **Get all products**: Full table scan on `products` (cached in app)
3. **Get user orders**: Prefix scan on `orders_by_user` table
4. **Get recent orders**: Time-range scan on `orders` table
5. **Get store details**: Direct row key lookup on `stores` table

### Performance Optimization:
- Product catalog is small, cache in memory
- Use row key prefix scanning for related data
- Implement pagination for order history (limit + start key)
- Set appropriate TTL on session data

---

## Data Consistency

### Write Operations:
- All writes use `CheckAndMutate` for conditional updates
- Order status changes logged for audit trail
- User profile updates maintain version history (max 3 versions)

### Read Operations:
- Eventually consistent reads acceptable for most data
- Strong consistency required for payment status checks
- Cache frequently accessed data (products, stores) in app

---

## Backup and Retention

- **Daily backups**: Automated backup of all tables
- **Retention**: 30 days for backups
- **Point-in-time recovery**: Available for critical tables (orders, users)
- **Archive strategy**: Move completed orders older than 1 year to cold storage

---

## Security

- **IAM roles**: Separate service accounts for read/write operations
- **Encryption**: At-rest and in-transit encryption enabled
- **PII handling**: Hash sensitive data (passwords, payment details)
- **Access logging**: Enable audit logs for compliance

---

## Monitoring

Key metrics to monitor:
- Read/write latency (p50, p99)
- CPU utilization
- Storage utilization
- Error rates
- Hot spotting (check row key distribution)


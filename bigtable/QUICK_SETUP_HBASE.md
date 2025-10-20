# Quick Setup Guide - HBase Local

Hướng dẫn nhanh để setup HBase local cho dự án Highland Coffee.

## 🚀 Bước 1: Khởi động HBase

### Linux/Mac:
```bash
# Start HBase
cd $HBASE_HOME
./bin/start-hbase.sh

# Kiểm tra HBase đang chạy
jps
# Bạn sẽ thấy: HMaster, HRegionServer
```

### Windows:
```bash
# Start HBase
cd %HBASE_HOME%
bin\start-hbase.cmd

# Hoặc chạy Docker:
docker run -d -p 2181:2181 -p 16000:16000 -p 16010:16010 -p 16020:16020 -p 16030:16030 --name hbase harisekhon/hbase
```

### Kiểm tra HBase Web UI:
Mở trình duyệt: http://localhost:16010

---

## 📦 Bước 2: Tạo Tables

Chạy script setup:

```bash
cd bigtable

# Cấp quyền execute
chmod +x setup_local_hbase.sh

# Chạy script
./setup_local_hbase.sh
```

Script sẽ tạo 10 tables:
- ✅ users
- ✅ products
- ✅ stores
- ✅ orders
- ✅ orders_by_user
- ✅ sessions
- ✅ carts
- ✅ deliveries
- ✅ promotions
- ✅ payments

---

## 🌱 Bước 3: Thêm dữ liệu mẫu

```bash
# Cấp quyền execute
chmod +x seed_local_hbase.sh

# Chạy script
./seed_local_hbase.sh
```

Dữ liệu mẫu bao gồm:
- 8 sản phẩm (cafe, trà, smoothie, bánh)
- 5 cửa hàng tại TP.HCM
- 3 mã khuyến mãi

---

## ✅ Bước 4: Kiểm tra

### Dùng HBase Shell:
```bash
hbase shell

# List tất cả tables
> list

# Xem structure của table
> describe 'products'

# Xem dữ liệu
> scan 'products', {LIMIT => 5}
> scan 'stores'
> scan 'promotions'

# Xem chi tiết 1 record
> get 'products', 'product#p001'

# Thoát
> exit
```

### Kết quả mong đợi:
```
hbase(main):001:0> list
TABLE
carts
deliveries
orders
orders_by_user
payments
products
promotions
sessions
stores
users
10 row(s) in 0.0120 seconds

hbase(main):002:0> scan 'products', {LIMIT => 3}
ROW                          COLUMN+CELL
 product#p001                column=info:category, value=coffee
 product#p001                column=info:description, value=Cà phê phin truyền thống...
 product#p001                column=info:name, value=Phin Sữa Đá
 product#p001                column=info:price, value=39000
 ...
```

---

## 🔧 Bước 5: Cấu hình Backend

### 1. Tạo file `.env` trong thư mục `backend/`:

```env
PORT=8080
NODE_ENV=development

# HBase Local Configuration
HBASE_HOST=localhost
HBASE_PORT=2181
HBASE_ZOOKEEPER_QUORUM=localhost

# Hoặc nếu dùng Bigtable
GCP_PROJECT_ID=your-project-id
BIGTABLE_INSTANCE_ID=highlands-coffee
GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account.json

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=30d

# CORS
ALLOWED_ORIGINS=*
```

### 2. Cài đặt dependencies:

```bash
cd backend
npm install
```

### 3. Khởi động server:

```bash
npm run dev
```

Server sẽ chạy tại: http://localhost:8080

---

## 🧪 Bước 6: Test API

### Sử dụng REST Client (VS Code):

1. Cài extension "REST Client" trong VS Code
2. Mở file `backend/test_api.http`
3. Click "Send Request" trên các endpoints

### Hoặc dùng curl:

```bash
# Health check
curl http://localhost:8080/health

# Register user
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@highlands.vn",
    "password": "password123",
    "name": "Test User",
    "phone": "0901234567"
  }'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@highlands.vn",
    "password": "password123"
  }'

# Get products (cần JWT token từ login)
curl http://localhost:8080/api/products \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## 🛠️ Commands Hữu ích

### HBase Shell Commands:

```bash
# Xem tất cả tables
list

# Xem structure
describe 'table_name'

# Scan toàn bộ table
scan 'table_name'

# Scan với limit
scan 'table_name', {LIMIT => 10}

# Get 1 row cụ thể
get 'table_name', 'row_key'

# Count số rows
count 'table_name'

# Xóa 1 row
deleteall 'table_name', 'row_key'

# Disable và drop table
disable 'table_name'
drop 'table_name'

# Truncate table (xóa toàn bộ dữ liệu)
truncate 'table_name'
```

### Tạo thủ công 1 table:

```bash
hbase shell

# Tạo table với column families
create 'test_table', {NAME => 'cf1', VERSIONS => 1}, {NAME => 'cf2', VERSIONS => 1}

# Thêm dữ liệu
put 'test_table', 'row1', 'cf1:col1', 'value1'
put 'test_table', 'row1', 'cf1:col2', 'value2'

# Xem dữ liệu
get 'test_table', 'row1'
scan 'test_table'
```

---

## 🐛 Troubleshooting

### Lỗi: "HBase command not found"
```bash
# Thêm HBase vào PATH
export HBASE_HOME=/path/to/hbase
export PATH=$PATH:$HBASE_HOME/bin
```

### Lỗi: "Could not start ZooKeeper"
```bash
# Kiểm tra port 2181 đã được sử dụng chưa
lsof -i :2181

# Kill process nếu cần
kill -9 <PID>

# Restart HBase
stop-hbase.sh
start-hbase.sh
```

### Lỗi: "Connection refused"
```bash
# Kiểm tra HBase có đang chạy không
jps | grep HMaster

# Xem logs
tail -f $HBASE_HOME/logs/hbase-*-master-*.log
```

### Tables không được tạo:
```bash
# Chạy từng command một trong HBase shell
hbase shell

# Copy paste từng command trong setup_local_hbase.sh
create 'users', {NAME => 'profile', VERSIONS => 1}, {NAME => 'auth', VERSIONS => 1}
# ...
```

---

## 📚 Tài liệu tham khảo

- [HBase Documentation](https://hbase.apache.org/book.html)
- [HBase Shell Commands](https://learnhbase.wordpress.com/2013/03/02/hbase-shell-commands/)
- [Backend API Documentation](../backend/API_DOCUMENTATION.md)
- [Database Schema](./schema.md)

---

## ✨ Next Steps

Sau khi setup xong HBase:

1. ✅ Test các API endpoints với Postman hoặc REST Client
2. ✅ Tích hợp Flutter app với backend API
3. ✅ Deploy backend lên server (Google Cloud, AWS, etc.)
4. ✅ Setup monitoring và logging
5. ✅ Cấu hình backup tự động

---

## 🆘 Cần trợ giúp?

Nếu gặp vấn đề:
1. Kiểm tra logs: `$HBASE_HOME/logs/`
2. Xem HBase Web UI: http://localhost:16010
3. Test connection: `echo "list" | hbase shell`
4. Đọc error messages cẩn thận

Good luck! 🚀





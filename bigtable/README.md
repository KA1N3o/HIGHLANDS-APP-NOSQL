# Highland Coffee - HBase Database Setup

Hướng dẫn setup HBase database cho dự án Highland Coffee API.

## 📋 Tổng quan

Dự án sử dụng HBase (hoặc Google Cloud Bigtable) làm database chính với 10 tables:

| Table | Mô tả | Column Families |
|-------|-------|-----------------|
| **users** | Thông tin người dùng | `profile`, `auth` |
| **products** | Danh mục sản phẩm | `info`, `options` |
| **stores** | Cửa hàng | `info`, `hours` |
| **orders** | Đơn hàng | `info`, `payment`, `items` |
| **orders_by_user** | Index user orders | `ref` |
| **sessions** | JWT sessions | `data` (TTL: 30 days) |
| **carts** | Giỏ hàng | `items`, `meta` |
| **deliveries** | Giao hàng | `info` |
| **promotions** | Khuyến mãi | `info` |
| **payments** | Thanh toán | `info` |

---

## 🚀 Quick Start (3 bước)

### Bước 1: Khởi động HBase

```bash
# Linux/Mac
$HBASE_HOME/bin/start-hbase.sh

# Windows (PowerShell)
cd $env:HBASE_HOME
.\bin\start-hbase.cmd

# Hoặc Docker
docker run -d -p 2181:2181 -p 16010:16010 --name hbase harisekhon/hbase
```

Kiểm tra: http://localhost:16010

### Bước 2: Tạo tables

**Cách 1: Tự động (Linux/Mac)**
```bash
cd bigtable
chmod +x setup_local_hbase.sh
./setup_local_hbase.sh
```

**Cách 2: Thủ công (Windows/All OS)**
```bash
# Mở HBase shell
hbase shell

# Copy paste từng dòng trong file: create_tables_manual.txt
# Hoặc chạy:
```

Mở file `create_tables_manual.txt` và copy-paste từng command vào HBase shell.

### Bước 3: Thêm dữ liệu mẫu

**Tự động:**
```bash
chmod +x seed_local_hbase.sh
./seed_local_hbase.sh
```

**Thủ công:** Copy commands từ file `seed_local_hbase.sh`

---

## 📝 Files trong thư mục này

| File | Mục đích |
|------|----------|
| `schema.md` | ⭐ Chi tiết cấu trúc database |
| `QUICK_SETUP_HBASE.md` | ⭐ Hướng dẫn chi tiết từng bước |
| `setup_local_hbase.sh` | Script tạo tables (Linux/Mac) |
| `seed_local_hbase.sh` | Script thêm dữ liệu mẫu (Linux/Mac) |
| `create_tables_manual.txt` | ⭐ Commands tạo tables (All OS) |
| `setup.sh` | Setup cho Google Cloud Bigtable |
| `seed_data.sh` | Seed data cho Google Cloud Bigtable |

---

## ✅ Kiểm tra sau khi setup

### 1. List tables
```bash
hbase shell
> list
```

Kết quả mong đợi:
```
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
```

### 2. Xem dữ liệu
```bash
> scan 'products', {LIMIT => 3}
> scan 'stores'
> scan 'promotions'
```

### 3. Chi tiết 1 record
```bash
> get 'products', 'product#p001'
```

Kết quả mong đợi:
```
COLUMN                    CELL
info:name                Phin Sữa Đá
info:price               39000
info:category            coffee
options:sizes            ["Small","Medium","Large"]
...
```

---

## 🔧 Cấu hình Backend

Sau khi tạo tables, cấu hình backend:

### 1. Tạo file `backend/.env`:

```env
PORT=8080
NODE_ENV=development

# HBase Local
HBASE_HOST=localhost
HBASE_PORT=2181

# JWT
JWT_SECRET=your-secret-key-change-this
JWT_EXPIRES_IN=30d

# CORS
ALLOWED_ORIGINS=*
```

### 2. Chạy backend:

```bash
cd backend
npm install
npm run dev
```

Server chạy tại: http://localhost:8080

---

## 🧪 Test API

### REST Client (VS Code)

1. Cài extension "REST Client"
2. Mở file `backend/test_api.http`
3. Click "Send Request"

### cURL

```bash
# Register
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"123456","name":"Test","phone":"0901234567"}'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"123456"}'

# Get products (cần token từ login)
curl http://localhost:8080/api/products \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 📚 Tài liệu

- **[schema.md](./schema.md)** - Chi tiết cấu trúc database
- **[QUICK_SETUP_HBASE.md](./QUICK_SETUP_HBASE.md)** - Hướng dẫn setup chi tiết
- **[../backend/API_DOCUMENTATION.md](../backend/API_DOCUMENTATION.md)** - API endpoints
- **[../backend/README_VN.md](../backend/README_VN.md)** - Backend documentation

---

## 🐛 Troubleshooting

### HBase không khởi động được
```bash
# Kiểm tra port 2181
netstat -an | grep 2181

# Xem logs
tail -f $HBASE_HOME/logs/hbase-*.log
```

### Tables không tạo được
```bash
# Chạy từng command một trong HBase shell
hbase shell
> create 'test', 'cf'
> list
> drop 'test'
```

### Backend không connect được HBase
- Kiểm tra HBase đang chạy: `jps | grep HMaster`
- Kiểm tra file `.env` có đúng config
- Xem logs backend để biết lỗi cụ thể

---

## 🎯 Next Steps

1. ✅ Tạo tables trong HBase
2. ✅ Thêm dữ liệu mẫu
3. ✅ Chạy backend server
4. ✅ Test các API endpoints
5. ✅ Tích hợp với Flutter app
6. ✅ Deploy lên production

---

## 📞 Support

Nếu gặp vấn đề, check:
1. HBase Web UI: http://localhost:16010
2. Backend logs khi chạy `npm run dev`
3. HBase logs: `$HBASE_HOME/logs/`

Happy coding! 🚀

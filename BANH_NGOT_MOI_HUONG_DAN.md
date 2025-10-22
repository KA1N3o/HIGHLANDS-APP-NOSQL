# Hướng Dẫn: Thêm 5 Bánh Ngọt Mới ✅

## ✨ Tóm Tắt

Đã thêm thành công **5 loại bánh ngọt mới** vào HBase! 

### Sản Phẩm Mới:
1. ✅ **Bánh Su Kem** (product#pastry007) - 38,000₫
2. ✅ **Bánh Sữa Chua Phô Mai** (product#pastry008) - 45,000₫  
3. ✅ **Bánh Phô Mai Trà Xanh** (product#pastry009) - 48,000₫
4. ✅ **Bánh Phô Mai Chanh Dây** (product#pastry010) - 48,000₫
5. ✅ **Mousse Cacao** (product#pastry011) - 52,000₫

---

## 🎯 Trạng Thái

### ✅ Đã Hoàn Thành:
- [x] Data đã được thêm vào HBase
- [x] Cập nhật file PRODUCTS_LIST.md (47 → 52 sản phẩm)
- [x] Thêm method clearCache() vào productService
- [x] Thêm endpoint POST /api/admin/cache/clear
- [x] Tạo các scripts test và verify

### ⚠️ Cần Làm:
- [ ] **Restart Backend** để load code mới và clear cache

---

## 🚀 Cách Kiểm Tra

### Bước 1: Restart Backend

**Cách 1 - Nếu backend đang chạy trong terminal:**
```bash
# Nhấn Ctrl+C để dừng
# Sau đó chạy lại:
cd backend
npm start
```

**Cách 2 - Sử dụng script:**
```bash
.\start_backend.bat
```

### Bước 2: Kiểm Tra Sản Phẩm

Sau khi restart, chạy script test:
```powershell
.\restart_backend_and_test.ps1
```

Hoặc check thủ công qua API:
```bash
# Login
POST http://localhost:8080/api/auth/login
{
  "email": "admin@highlands.vn",
  "password": "admin123"
}

# Get pastry products (với token từ login)
GET http://localhost:8080/api/products?category=pastry
Authorization: Bearer <YOUR_TOKEN>
```

---

## 🗂️ Files Đã Tạo

### Scripts:
- `bigtable/add_new_pastries.ps1` - Script PowerShell thêm bánh
- `bigtable/hbase_new_pastries.txt` - Lệnh HBase
- `bigtable/add_pastries_simple.bat` - Batch file đơn giản
- `bigtable/add_pastries_via_api.ps1` - Script thêm qua API
- `test_new_pastries.ps1` - Script kiểm tra
- `clear_cache_and_test.ps1` - Script clear cache và test
- `restart_backend_and_test.ps1` - Script hướng dẫn restart

### Documentation:
- `bigtable/ADD_NEW_PASTRIES_README.md` - Hướng dẫn chi tiết
- `BANH_NGOT_MOI_HUONG_DAN.md` - File này

---

## 🔍 Verify trong HBase

Data đã được confirm có trong HBase:
```bash
docker exec hbase hbase shell /tmp/check_pastry.txt
```

Kết quả: **11 sản phẩm pastry** (6 cũ + 5 mới) ✅

---

## ❓ Tại Sao Backend Chưa Thấy?

Backend có **cache 10 phút** trong `productService.js`. Có 2 cách:

**Cách 1: Đợi** - Cache tự hết sau 10 phút

**Cách 2: Restart** - Backend sẽ load lại data ngay lập tức (Khuyến nghị)

---

## 📊 Tổng Kết

| Hạng Mục | Trước | Sau |
|----------|-------|-----|
| Tổng sản phẩm | 47 | **52** |
| Bánh ngọt | 6 | **11** |
| Giá cao nhất (Đồ ăn) | 45,000₫ | **52,000₫** |

---

## 🎯 Next Steps

1. **Restart backend** (quan trọng nhất!)
2. Kiểm tra trên app Flutter
3. Test đặt hàng với bánh mới
4. Cập nhật hình ảnh sản phẩm nếu cần

---

**Tạo bởi:** AI Assistant  
**Ngày:** 22/10/2025  
**Trạng thái:** Đã thêm vào HBase, chờ restart backend ✅


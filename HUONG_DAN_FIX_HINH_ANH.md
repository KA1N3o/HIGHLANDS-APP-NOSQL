# Hướng Dẫn Fix Hình Ảnh Bánh Ngọt

## ✅ Tình Trạng Hiện Tại

Backend đã có **11 bánh ngọt** với đầy đủ hình ảnh:
- 6 bánh cũ (pastry001-006) ✅
- 5 bánh mới (pastry007-011) ✅

**Tất cả đã có URL hình ảnh hợp lệ!**

---

## 🔧 Cách Fix "No Image" Trong App

### **Cách 1: Hot Restart Flutter App (Nhanh nhất)**

1. Mở terminal đang chạy Flutter app
2. Nhấn phím `Shift + R` (Hot Restart)
3. Hoặc nhấn `r` (Hot Reload)

### **Cách 2: Dừng và Chạy Lại App**

```bash
# Dừng app (Ctrl + C)
# Rồi chạy lại:
flutter run
```

### **Cách 3: Clear Cache và Rebuild**

```bash
flutter clean
flutter pub get
flutter run
```

---

## 🧪 Kiểm Tra API Trực Tiếp

Chạy script test để xác nhận backend có đủ data:

```powershell
.\test_sau_restart.ps1
```

Kết quả mong đợi:
```
✅ 11 bánh ngọt
✅ Tất cả đều có imageUrl
```

---

## 📱 Kiểm Tra Trong App

1. **Vào màn hình Products** hoặc **Bánh Ngọt**
2. **Cuộn xuống** để xem các bánh mới:
   - ✅ Bánh Su Kem - 38,000₫
   - ✅ Bánh Sữa Chua Phô Mai - 45,000₫
   - ✅ Bánh Phô Mai Trà Xanh - 48,000₫
   - ✅ Bánh Phô Mai Chanh Dây - 48,000₫
   - ✅ Mousse Cacao - 52,000₫

---

## 🔍 Troubleshooting

### Nếu vẫn "No Image":

#### 1. **Kiểm tra Internet Connection**
   - Hình ảnh load từ Unsplash.com
   - Cần kết nối internet

#### 2. **Kiểm tra Console/Logs**
   - Xem có lỗi `CachedNetworkImage error` không
   - Xem có lỗi network không

#### 3. **Clear App Data** (Android/iOS)
   ```bash
   # Uninstall rồi install lại
   flutter clean
   flutter run
   ```

#### 4. **Kiểm tra URL hình ảnh**
   - Test URL trong browser:
   ```
   https://images.unsplash.com/photo-1612201142855-e7f82f9ab9e8?w=400&h=300&fit=crop
   ```

---

## 📊 Danh Sách Hình Ảnh Mới

| Bánh | URL |
|------|-----|
| Bánh Su Kem | https://images.unsplash.com/photo-1612201142855-e7f82f9ab9e8?w=400&h=300&fit=crop |
| Bánh Sữa Chua Phô Mai | https://images.unsplash.com/photo-1621303837174-89787a7d4729?w=400&h=300&fit=crop |
| Bánh Phô Mai Trà Xanh | https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400&h=300&fit=crop |
| Bánh Phô Mai Chanh Dây | https://images.unsplash.com/photo-1533134242820-31a6d23e64b4?w=400&h=300&fit=crop |
| Mousse Cacao | https://images.unsplash.com/photo-1586985289688-ca3cf47d3e6e?w=400&h=300&fit=crop |

---

## ✅ Checklist Hoàn Thành

- [x] Tạo 5 bánh ngọt mới trong HBase
- [x] Thêm URL hình ảnh với parameters
- [x] Update backend code (clearCache function)
- [x] Clear cache backend
- [x] Kiểm tra API - có 11 bánh ngọt
- [ ] **Hot Restart Flutter App** ← BẠN CẦN LÀM BƯỚC NÀY
- [ ] Kiểm tra hình ảnh hiển thị trong app

---

## 🎯 Bước Tiếp Theo

**Chỉ cần làm 1 việc:**

1. Mở terminal Flutter app
2. Nhấn **Shift + R**
3. Kiểm tra lại app

**Hoặc đơn giản hơn: Tắt app và mở lại!**

---

Nếu vẫn còn vấn đề, hãy cho tôi biết lỗi cụ thể trong console! 🚀


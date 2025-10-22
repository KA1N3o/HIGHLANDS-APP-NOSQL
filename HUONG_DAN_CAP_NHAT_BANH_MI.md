# Hướng Dẫn Cập Nhật "Bánh Mì"

## ✅ Đã Hoàn Thành

### Backend:
- ✅ Đã đổi tên category "Đồ ăn" → "**Bánh Mì**" 🥖
- ✅ Đã thêm category "**Freeze**" 🧊
- ✅ Đã di chuyển 2 Croissant từ Bánh Ngọt → Bánh Mì
- ✅ Backend đã restart và trả về data mới

### Database:
- ✅ Croissant Bơ (pastry001) → category: food
- ✅ Croissant Chocolate (pastry002) → category: food

---

## 📊 Kết Quả

### **Danh Mục Mới:**
1. ☕ Cà phê
2. 🍵 Trà
3. 🧊 **Freeze** ← MỚI
4. 🥤 Sinh tố
5. 🥖 **Bánh Mì** ← ĐÃ ĐỔI TÊN
6. 🧁 Bánh ngọt
7. 🎁 Sản phẩm

### **Bánh Mì (5 sản phẩm):**
- Bánh Mì Que Bò Phô Mai - 35,000₫
- Bánh Mì Que Gà Phô Mai - 35,000₫
- Bánh Mì Que Pate - 32,000₫
- **Croissant Bơ - 35,000₫** ← từ Bánh Ngọt
- **Croissant Chocolate - 38,000₫** ← từ Bánh Ngọt

### **Bánh Ngọt (9 sản phẩm):**
- Bánh Tiramisu - 45,000₫
- Bánh Cheesecake - 42,000₫
- Muffin Chocolate Chip - 32,000₫
- Muffin Blueberry - 32,000₫
- Bánh Su Kem - 38,000₫
- Bánh Sữa Chua Phô Mai - 45,000₫
- Bánh Phô Mai Trà Xanh - 48,000₫
- Bánh Phô Mai Chanh Dây - 48,000₫
- Mousse Cacao - 52,000₫

---

## 📱 Để Thấy Thay Đổi Trong Flutter App

### **QUAN TRỌNG: Phải làm các bước sau đây:**

#### **Bước 1: Hard Restart Flutter App**

Chỉ Hot Reload/Hot Restart (`r` hoặc `Shift+R`) **KHÔNG ĐỦ** cho thay đổi categories!

**Làm như sau:**

1. **Dừng app hoàn toàn**: 
   - Nhấn `q` trong terminal Flutter
   - Hoặc `Ctrl + C`

2. **Chạy lại app**:
   ```bash
   flutter run
   ```

#### **Bước 2: Hoặc Clear Cache (Nếu vẫn chưa được)**

```bash
flutter clean
flutter pub get
flutter run
```

---

## 🔍 Tại Sao Hot Restart Không Đủ?

- **Hot Restart** (`Shift + R`): Chỉ reload code Dart
- **Categories từ API**: Flutter app có thể cache lần đầu
- **Hard Restart**: Khởi động lại toàn bộ app, xóa cache

---

## ✅ Sau Khi Restart, Bạn Sẽ Thấy:

1. Tab **"Bánh Mì"** 🥖 (không còn "Đồ ăn")
2. Tab **"Freeze"** 🧊 mới xuất hiện
3. Trong tab **"Bánh Mì"**: có 5 sản phẩm (bao gồm 2 Croissant)
4. Trong tab **"Bánh Ngọt"**: còn 9 sản phẩm

---

## 🧪 Kiểm Tra Backend

Nếu muốn chắc chắn backend đúng, chạy:

```powershell
.\test_banh_mi_update.ps1
```

Kết quả sẽ hiển thị:
- ✅ Categories có "Bánh Mì"
- ✅ Bánh Mì có 5 sản phẩm
- ✅ Bánh Ngọt có 9 sản phẩm

---

## 🎯 TÓM TẮT

**Backend đã đúng rồi!**

**Bạn chỉ cần:**
1. Dừng Flutter app (`q`)
2. Chạy lại: `flutter run`
3. Xem kết quả!

---

**Nếu vẫn chưa được, báo cho tôi biết app hiển thị như thế nào nhé!** 🚀


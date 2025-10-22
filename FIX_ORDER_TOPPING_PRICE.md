# Fix: Topping không hiển thị trong hóa đơn và giá sai

## Vấn đề

Khi đặt hàng, trong hóa đơn chỉ hiển thị giá gốc + size, **không tính và không hiển thị topping**.

## Nguyên nhân

### Backend (orderService.js)
1. **Tính giá sai**: Khi tạo order, chỉ dùng `product.price * quantity`, không tính size và topping
2. **Không lưu topping**: orderItems không có field `selectedToppings`

### Frontend (order_detail_screen.dart, admin_orders_screen.dart)
3. **Không hiển thị topping**: UI chỉ hiển thị size, không hiển thị topping đã chọn

## Giải pháp đã áp dụng

### ✅ 1. Backend - Fix tính giá và lưu topping

**File**: `backend/src/services/orderService.js` (dòng 166-196)

```javascript
// TẠI SAO PHẢI SỬA:
// Code cũ chỉ lấy: itemTotal = product.price * quantity
// → Sai vì không tính size và topping!

// ĐÃ SỬA THÀNH:
// Calculate price with size and toppings
let itemPrice = product.price || 0;

// Add price for size (each size up is +30%)
const sizeIndex = product.sizes ? product.sizes.indexOf(item.size) : 0;
if (sizeIndex > 0) {
  for (let i = 0; i < sizeIndex; i++) {
    itemPrice *= 1.3;
  }
}

// Add price for toppings
if (item.selectedToppings && Array.isArray(item.selectedToppings)) {
  for (const topping of item.selectedToppings) {
    itemPrice += topping.price || 0;
  }
}

const itemTotal = itemPrice * (item.quantity || 0);

orderItems.push({
  productId: item.productId || '',
  name: product.name || 'Unknown Product',
  price: itemPrice, // ✅ Giá đã bao gồm size và topping
  quantity: item.quantity || 0,
  size: item.size || 'Medium',
  options: item.options || [],
  selectedToppings: item.selectedToppings || [], // ✅ Đã thêm
  total: itemTotal,
});
```

### ✅ 2. Frontend - Hiển thị topping trong hóa đơn

**File 1**: `lib/screens/order/order_detail_screen.dart` (dòng 344-356)

```dart
// Thêm vào phần hiển thị item:
if (item.selectedToppings.isNotEmpty) ...[
  const SizedBox(height: 2),
  Text(
    'Topping: ${item.selectedToppings.map((t) => t.name).join(', ')}',
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppTheme.primaryGreen,
      fontWeight: FontWeight.w500,
    ),
  ),
],
```

**File 2**: `lib/screens/admin/admin_orders_screen.dart` (dòng 503-512)

```dart
// Tương tự cho admin orders screen
if (item.selectedToppings.isNotEmpty) ...[
  const SizedBox(height: 2),
  Text(
    'Topping: ${item.selectedToppings.map((t) => t.name).join(', ')}',
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppTheme.primaryGreen,
      fontWeight: FontWeight.w500,
    ),
  ),
],
```

## Bạn cần làm ngay

### 1. **RESTART BACKEND** (BẮT BUỘC)

Backend code đã được sửa, cần restart để áp dụng:

```bash
# Stop backend hiện tại (Ctrl+C trong terminal backend)
cd backend
npm start
```

### 2. **Restart Flutter app**

```bash
# Stop app hiện tại (trong Android Studio/VS Code: Stop)
flutter run
```

### 3. **Test đặt hàng mới**

1. Chọn sản phẩm coffee/tea/freeze
2. Chọn size: **Lớn**
3. Chọn topping: **Trân Châu Dừa (10,000đ)** + **Kem Whip (15,000đ)**
4. Thêm vào giỏ hàng
5. Thanh toán

**Kết quả mong đợi trong hóa đơn:**

```
Mã đơn hàng: #ord0f35f
Cửa hàng: Highlands Coffee - Nguyen Hue
Phương thức: Nhận tại cửa hàng
Thời gian nhận: Sớm nhất

Phin Sữa Đá
Size: Lớn x1
Topping: Trân Châu Dừa, Kem Whip      ← ✅ PHẢI HIỂN THỊ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tạm tính:         83,500đ  ← ✅ PHẢI ĐÚNG
Thuế (8%):         6,680đ
Phí giao hàng:         0đ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tổng cộng:        90,180đ  ← ✅ GIÁ ĐÚNG
```

**Tính toán chi tiết:**
- Giá cơ bản Phin Sữa Đá: 45,000đ
- Size Lớn (×1.3): 58,500đ
- Trân Châu Dừa: +10,000đ
- Kem Whip: +15,000đ
- **Tạm tính: 83,500đ** ✅
- Thuế 8%: 6,680đ
- **Tổng: 90,180đ** ✅

## Kiểm tra Admin Panel

1. Login admin: `admin@highlands.vn / admin123`
2. Vào **Quản lý đơn hàng**
3. Xem đơn hàng vừa tạo
4. Phải thấy:
   - Topping hiển thị với màu xanh
   - Giá đúng (đã bao gồm topping)

## Các file đã sửa

✅ **Backend**
- `backend/src/services/orderService.js` - Tính giá đúng + lưu topping

✅ **Frontend**  
- `lib/screens/order/order_detail_screen.dart` - Hiển thị topping trong hóa đơn
- `lib/screens/admin/admin_orders_screen.dart` - Hiển thị topping trong admin panel

## Checklist

- [x] Fix backend tính giá với size và topping
- [x] Thêm selectedToppings vào orderItems
- [x] Hiển thị topping trong order detail screen
- [x] Hiển thị topping trong admin orders screen
- [ ] **RESTART BACKEND** ← BẠN CẦN LÀM
- [ ] **RESTART FLUTTER APP** ← BẠN CẦN LÀM
- [ ] **TEST ĐẶT HÀNG MỚI** ← BẠN CẦN LÀM

## Lưu ý quan trọng

⚠️ **Đơn hàng CŨ** (đã đặt trước khi fix) vẫn sẽ có giá sai vì đã được lưu vào database.

✅ **Đơn hàng MỚI** (đặt sau khi restart backend) sẽ có giá đúng và hiển thị topping.

## Debug nếu vẫn sai

Nếu sau khi restart vẫn sai, kiểm tra:

1. **Backend console**: Xem log khi tạo order
   ```
   DEBUG: Calculate price with size and toppings
   itemPrice: 83500 (should include size and toppings)
   ```

2. **Flutter debug console**: Xem data order trả về
   ```dart
   print('Order items: ${order.items}');
   // Phải có selectedToppings
   ```

3. **API Response**: Check trong Network tab
   ```json
   {
     "items": [{
       "price": 83500,  // ← Phải đúng
       "selectedToppings": [...] // ← Phải có
     }]
   }
   ```

---

**Status**: ✅ Fixed - Waiting for restart  
**Date**: October 22, 2025  
**Priority**: HIGH - Affects order pricing and billing


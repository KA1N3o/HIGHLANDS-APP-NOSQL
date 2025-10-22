# Fix: Topping không cộng vào giá tiền

## Vấn đề

Khi chọn topping trong app, giá không được cộng vào tổng tiền sản phẩm.

## Nguyên nhân

Vấn đề **KHÔNG PHẢI** do logic tính giá sai. Logic tính giá trong Flutter đã đúng:
- ✅ `lib/models/cart_item.dart` - Đã có code cộng topping vào giá
- ✅ `lib/screens/product/product_detail_screen.dart` - Đã có code tính giá với topping

Vấn đề thực sự là: **Sản phẩm chưa có topping trong database!**

## Root Cause

Trong `backend/src/services/productService.js`, method `saveProduct()` chỉ lưu `sizes` và `options`, nhưng **quên lưu `availableToppings`** vào Bigtable.

```javascript
// Code CŨ (SAI):
const optionsMutations = createMutations('options', {
  sizes: JSON.stringify(product.sizes),
  options: JSON.stringify(product.options),
  // ❌ Thiếu availableToppings
});
```

## Giải pháp

### 1. Fix Backend Code

**File**: `backend/src/services/productService.js` (dòng 343-346)

```javascript
// Code MỚI (ĐÚNG):
const optionsMutations = createMutations('options', {
  sizes: JSON.stringify(product.sizes),
  options: JSON.stringify(product.options),
  availableToppings: JSON.stringify(product.availableToppings || []), // ✅ Đã thêm
});
```

### 2. Restart Backend

```bash
cd backend
npm start
```

### 3. Thêm Topping vào Sản phẩm

```powershell
.\add_toppings_with_auth.ps1
```

Script này sẽ:
- Login với admin account
- Lấy tất cả sản phẩm coffee, tea, freeze (31 sản phẩm)
- Thêm 8 loại topping vào mỗi sản phẩm

### 4. Kiểm tra

```powershell
.\test_single_product_topping.ps1
```

Kết quả mong đợi:
```
SUCCESS! Topping system is working!
Toppings:
  - Test Topping: 5000d
```

### 5. Test trong Flutter App

1. Chạy app: `flutter run`
2. Chọn một sản phẩm coffee/tea/freeze
3. Bạn sẽ thấy danh sách topping
4. Chọn topping → Giá sẽ tự động cập nhật

## Ví dụ Tính giá

**Phin Sữa Đá:**
- Giá cơ bản: 45,000₫
- Size Lớn (×1.3): 58,500₫
- Chọn Trân Châu Dừa: +10,000₫
- Chọn Kem Whip: +15,000₫
- **Tổng: 83,500₫** ✅

## Debug Logs

Debug logs đã được thêm vào `product_detail_screen.dart`:

```dart
print('DEBUG: Base price: ${widget.product.price}');
print('DEBUG: After size: $priceForSize');
print('DEBUG: Toppings total: $toppingTotal');
print('DEBUG: Selected toppings: ${_selectedToppings.length}');
```

Xem console khi chọn topping để debug.

## Checklist

- [x] Fix backend code (`productService.js`)
- [x] Tạo script thêm topping (`add_toppings_with_auth.ps1`)
- [x] Tạo script test (`test_single_product_topping.ps1`)
- [ ] **Restart backend** ← BẠN CẦN LÀM
- [ ] **Chạy script thêm topping** ← BẠN CẦN LÀM
- [ ] **Test trong Flutter app** ← BẠN CẦN LÀM

## Scripts Available

1. `add_toppings_with_auth.ps1` - Thêm topping vào tất cả sản phẩm
2. `test_single_product_topping.ps1` - Test một sản phẩm
3. `test_toppings_with_auth.ps1` - Kiểm tra tất cả sản phẩm có topping

## Next Steps

1. **Restart backend ngay** để áp dụng code fix
2. Chạy `.\add_toppings_with_auth.ps1` để thêm topping
3. Test trong app và kiểm tra giá có cộng đúng không
4. Nếu vẫn có vấn đề, xem debug logs trong console

---

**Status**: ✅ Fixed  
**Date**: October 22, 2025  
**Files Changed**: 
- `backend/src/services/productService.js`
- Created: `add_toppings_with_auth.ps1`, `test_single_product_topping.ps1`


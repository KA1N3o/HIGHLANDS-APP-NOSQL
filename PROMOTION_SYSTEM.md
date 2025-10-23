# Hệ thống Mã giảm giá - Promotion System

## Tổng quan

Hệ thống mã giảm giá cho phép:
- **Admin**: Tạo, sửa, xóa các mã giảm giá
- **User**: Áp dụng mã giảm giá khi đặt hàng

## Các tính năng đã thêm

### 1. Backend (Node.js)

#### Model: `backend/src/models/Promotion.js`
- `code`: Mã giảm giá (VD: SUMMER2024)
- `name`: Tên chương trình
- `type`: Loại giảm giá
  - `percentage`: Phần trăm (%)
  - `fixed_amount`: Số tiền cố định (VNĐ)
  - `free_shipping`: Miễn phí ship
- `value`: Giá trị giảm (% hoặc VNĐ)
- `minOrderValue`: Giá trị đơn hàng tối thiểu
- `maxDiscount`: Giảm tối đa (cho type percentage)
- `usageLimit`: Số lần sử dụng tối đa
- `usageCount`: Số lần đã sử dụng
- `startDate`, `endDate`: Thời gian hiệu lực
- `isActive`: Trạng thái bật/tắt

#### Service: `backend/src/services/promotionService.js`
- `createPromotion()`: Tạo mã mới
- `getPromotionById()`: Lấy theo ID
- `getPromotionByCode()`: Lấy theo mã code
- `applyPromotion()`: Validate và tính discount
- `updatePromotion()`: Cập nhật mã
- `deletePromotion()`: Xóa mã
- `getAllPromotions()`: Lấy tất cả
- `incrementUsage()`: Tăng số lần sử dụng

#### Routes Admin: `backend/src/routes/admin.js`
- `GET /api/admin/promotions` - Lấy tất cả mã
- `POST /api/admin/promotions` - Tạo mã mới
- `PUT /api/admin/promotions/:id` - Cập nhật mã
- `DELETE /api/admin/promotions/:id` - Xóa mã

#### Routes User: `backend/src/routes/promotions.js`
- `GET /api/promotions` - Lấy mã đang hoạt động
- `GET /api/promotions/:code` - Lấy theo code
- `POST /api/promotions/validate` - Validate mã

#### Order Service: `backend/src/services/orderService.js`
- Tự động áp dụng discount khi tạo order
- Tăng usage count khi sử dụng thành công
- Lưu promotion code vào order

### 2. Frontend (Flutter)

#### Model: `lib/models/promotion.dart`
- Enum `PromotionType`: percentage, fixedAmount, freeShipping
- Class `Promotion` với các thuộc tính tương ứng backend
- Methods: `isValid`, `calculateDiscount`, `toJson`, `fromJson`

#### Provider: `lib/providers/promotion_provider.dart`
- `loadActivePromotions()`: Load mã active cho user
- `loadAllPromotions()`: Load tất cả mã cho admin
- `applyPromotion(code, orderValue)`: Áp dụng mã
- `removePromotion()`: Xóa mã đã áp dụng
- `updateDiscount(orderValue)`: Cập nhật discount khi giá thay đổi
- `createPromotion()`: Tạo mã mới (admin)
- `updatePromotion()`: Cập nhật mã (admin)
- `deletePromotion()`: Xóa mã (admin)

#### API Service: `lib/services/api_service.dart`
Thêm các methods:
- `getActivePromotions()`
- `validatePromotion(code, orderValue)`
- `getAllPromotions()` (admin)
- `createPromotion()` (admin)
- `updatePromotion()` (admin)
- `deletePromotion()` (admin)

#### Admin Screen: `lib/screens/admin/admin_promotions_screen.dart`
- Hiển thị danh sách mã giảm giá
- Trạng thái: Đang hoạt động / Đã tắt / Hết hạn / Chưa bắt đầu / Hết lượt
- Form tạo/sửa mã với các options:
  - Loại giảm giá (%, số tiền, miễn phí ship)
  - Giá trị giảm
  - Đơn tối thiểu
  - Giảm tối đa (cho %)
  - Giới hạn số lần dùng
  - Ngày bắt đầu/kết thúc
  - Bật/tắt

#### Cart Screen: `lib/screens/cart/cart_screen.dart`
- Text field nhập mã giảm giá
- Nút "Áp dụng" để validate mã
- Hiển thị mã đã áp dụng với tên chương trình
- Nút xóa mã
- Hiển thị dòng "Giảm giá: -XX,XXXđ"
- Tổng tiền tự động trừ discount

#### Checkout Screen: `lib/screens/checkout/checkout_screen.dart`
- Tự động gửi promotion code khi tạo order
- Gửi discount amount vào order
- Clear promotion sau khi đặt hàng thành công

#### Order Model: `lib/models/order.dart`
- Thêm field `promotionCode` và `discount`
- Cập nhật `toJson()` để gửi lên backend

#### Navigation: `lib/screens/home/home_screen.dart`
- Thêm menu "Quản lý mã giảm giá" trong Admin Panel

## Cách sử dụng

### Admin - Tạo mã giảm giá

1. Đăng nhập với tài khoản admin
2. Mở menu → "QUẢN TRỊ" → "Quản lý mã giảm giá"
3. Nhấn nút "Tạo mã giảm giá" (+)
4. Điền thông tin:
   - Mã giảm giá (VD: SUMMER2024)
   - Tên chương trình
   - Loại giảm giá
   - Giá trị
   - Đơn tối thiểu (tùy chọn)
   - Giảm tối đa (nếu chọn %)
   - Giới hạn số lần (tùy chọn)
   - Ngày bắt đầu/kết thúc
   - Bật/Tắt
5. Nhấn "Lưu"

### User - Sử dụng mã giảm giá

1. Thêm sản phẩm vào giỏ hàng
2. Vào giỏ hàng
3. Nhập mã giảm giá vào ô "Nhập mã giảm giá"
4. Nhấn "Áp dụng"
5. Nếu hợp lệ, sẽ thấy:
   - Mã được hiển thị với tên chương trình
   - Dòng "Giảm giá" xuất hiện
   - Tổng tiền tự động giảm
6. Tiến hành thanh toán như bình thường

## Validation Rules

Mã giảm giá sẽ **không hợp lệ** nếu:
- Mã không tồn tại
- Đã bị tắt (isActive = false)
- Chưa đến ngày bắt đầu
- Đã hết hạn (quá endDate)
- Đã hết lượt sử dụng (usageCount >= usageLimit)
- Đơn hàng không đủ giá trị tối thiểu

## Ví dụ mã giảm giá

### 1. Giảm 10% (tối đa 50k)
```json
{
  "code": "GIAM10",
  "name": "Giảm 10% cho đơn từ 100k",
  "type": "percentage",
  "value": 10,
  "minOrderValue": 100000,
  "maxDiscount": 50000,
  "startDate": "2024-01-01",
  "endDate": "2024-12-31"
}
```

### 2. Giảm 30k cố định
```json
{
  "code": "GIAM30K",
  "name": "Giảm 30k cho đơn từ 200k",
  "type": "fixed_amount",
  "value": 30000,
  "minOrderValue": 200000,
  "startDate": "2024-01-01",
  "endDate": "2024-12-31"
}
```

### 3. Miễn phí ship
```json
{
  "code": "FREESHIP",
  "name": "Miễn phí giao hàng",
  "type": "free_shipping",
  "value": 0,
  "minOrderValue": 150000,
  "startDate": "2024-01-01",
  "endDate": "2024-12-31"
}
```

## Database (Bigtable)

### Table: promotions
- Row key: `promo#{uuid}`
- Column family: `info`
  - code
  - name
  - description
  - type
  - value
  - minOrderValue
  - maxDiscount
  - usageLimit
  - usageCount
  - startDate
  - endDate
  - isActive
  - createdAt
  - updatedAt

### Table: orders (cập nhật)
- Column family: `info`
  - promotionCode (new)
- Column family: `payment`
  - discount (new)

## Testing

### Test mã giảm giá
1. Tạo mã test: `TEST10` (giảm 10%, min 50k, max 20k)
2. Thêm sản phẩm vào giỏ > 50k
3. Áp dụng mã `TEST10`
4. Kiểm tra discount được tính đúng
5. Đặt hàng và xác nhận order có promotionCode

### Test validation
1. Nhập mã không tồn tại → Lỗi
2. Nhập mã đã hết hạn → Lỗi
3. Nhập mã với đơn < minOrderValue → Lỗi
4. Nhập mã đã hết lượt → Lỗi

## Notes

- Mỗi order chỉ áp dụng được 1 mã giảm giá
- Discount được tính trước thuế
- Backend tự động increment usage count khi tạo order thành công
- Frontend tự động clear promotion sau khi đặt hàng
- Admin có thể tắt mã bất kỳ lúc nào bằng cách toggle isActive

## Files đã thay đổi

### Backend
- `backend/src/models/Promotion.js` (đã có)
- `backend/src/services/promotionService.js` (đã có)
- `backend/src/routes/promotions.js` (đã có)
- `backend/src/routes/admin.js` (đã có - thêm promotion routes)
- `backend/src/services/orderService.js` (đã có - thêm promotion logic)

### Frontend
- `lib/models/promotion.dart` ✅ NEW
- `lib/providers/promotion_provider.dart` ✅ NEW
- `lib/screens/admin/admin_promotions_screen.dart` ✅ NEW
- `lib/services/api_service.dart` ✅ UPDATED
- `lib/main.dart` ✅ UPDATED (thêm provider và route)
- `lib/screens/home/home_screen.dart` ✅ UPDATED (thêm menu)
- `lib/screens/cart/cart_screen.dart` ✅ UPDATED (thêm UI mã giảm giá)
- `lib/screens/checkout/checkout_screen.dart` ✅ UPDATED (gửi promotion)
- `lib/models/order.dart` ✅ UPDATED (thêm promotionCode, discount)

## Troubleshooting

### Lỗi "No token provided" (401)

**Nguyên nhân**: API promotion yêu cầu authentication nhưng user chưa đăng nhập.

**Đã sửa**:
- ✅ `PromotionProvider.loadActivePromotions()` - Kiểm tra token trước khi gọi API
- ✅ `PromotionProvider.applyPromotion()` - Hiển thị thông báo yêu cầu đăng nhập
- ✅ Logout - Tự động clear promotions khi đăng xuất

**Cách khắc phục**: Đảm bảo user đã đăng nhập trước khi:
- Load danh sách mã giảm giá
- Áp dụng mã giảm giá

### Lỗi "Missing required fields" khi tạo promotion

**Nguyên nhân**: Backend validation sử dụng `!promotionData.value` sẽ fail khi `value = 0` (cho free_shipping type) vì `0` là falsy trong JavaScript.

**Đã sửa**:
- ✅ Backend `admin.js` - Thay đổi validation thành `value === undefined || value === null`
- ✅ Frontend `admin_promotions_screen.dart` - Thêm validation rõ ràng cho value field

**Fix**: 
```javascript
// Backend - admin.js (line 151-153)
if (!promotionData.code || !promotionData.name || !promotionData.type || 
    promotionData.value === undefined || promotionData.value === null ||
    !promotionData.startDate || !promotionData.endDate)
```

```dart
// Frontend - admin_promotions_screen.dart
double value = 0;
if (_selectedType == PromotionType.freeShipping) {
  value = 0;
} else {
  if (_valueController.text.trim().isEmpty) {
    // Show error
    return;
  }
  value = double.parse(_valueController.text.trim());
}
```

### Lỗi "Mất mã khi chuyển tab"

**Nguyên nhân**: Screen reload data từ server mỗi lần navigate vào lại, không sử dụng cache.

**Đã sửa**:
- ✅ `PromotionProvider` - Thêm caching 5 phút
- ✅ Khi create/update/delete - Tự động update cache time
- ✅ `loadAllPromotions()` - Chỉ reload từ server khi cache hết hạn
- ✅ Nút refresh - Force reload từ server

**Chi tiết**:
```dart
// PromotionProvider
DateTime? _lastLoadTime;
static const Duration _cacheValidDuration = Duration(minutes: 5);

Future<void> loadAllPromotions({bool forceRefresh = false}) async {
  // Return cached data if valid
  if (!forceRefresh && _isCacheValid && _promotions.isNotEmpty) {
    print('Returning ${_promotions.length} promotions from cache');
    return;
  }
  // Load from server...
}
```

### Lỗi "Get stores error: No token provided"

**Nguyên nhân**: StoreProvider cũng yêu cầu authentication.

**Đã sửa**:
- ✅ `StoreProvider.loadStores()` - Kiểm tra token trước khi gọi API
- ✅ Không throw error, chỉ log nếu chưa đăng nhập

## Notes

- Mỗi order chỉ áp dụng được 1 mã giảm giá
- Discount được tính trước thuế
- Backend tự động increment usage count khi tạo order thành công
- Frontend tự động clear promotion sau khi đặt hàng
- Admin có thể tắt mã bất kỳ lúc nào bằng cách toggle isActive
- **User phải đăng nhập để sử dụng mã giảm giá**
- Promotions tự động được clear khi logout

## Hoàn thành ✅

Tất cả các tính năng đã được implement, test và fix lỗi thành công!


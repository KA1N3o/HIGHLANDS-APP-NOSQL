# Fix: Product Update 404 Error

## Vấn đề
Khi cố gắng cập nhật sản phẩm từ admin panel, API trả về lỗi 404 "Product not found".

## Nguyên nhân
Product IDs có format `product#<uuid>` (ví dụ: `product#p001`). Khi gửi ID này trong URL path:
- **Không encode**: `http://localhost:8080/api/admin/products/product#p001`
- Ký tự `#` trong URL được coi là fragment identifier (anchor)
- Server chỉ nhận được `product` (phần sau `#` bị cắt bỏ)
- Không tìm thấy product với ID `product` → 404 error

## Giải pháp

### 1. Flutter Client - URL Encoding
Encode product ID trước khi gửi request:

**File**: `lib/services/api_service.dart`

```dart
// Encode product ID để xử lý ký tự đặc biệt như #
final encodedProductId = Uri.encodeComponent(productId);

// product#p001 → product%23p001
final response = await _client.put(
  Uri.parse('$baseUrl/admin/products/$encodedProductId'),
  ...
);
```

### 2. Backend - URL Decoding
Decode product ID khi nhận request:

**File**: `backend/src/routes/admin.js`

```javascript
router.put('/products/:productId', async (req, res) => {
  // Decode URL-encoded product ID
  const productId = decodeURIComponent(req.params.productId);
  // product%23p001 → product#p001
  ...
});
```

### 3. Debug Logging
Đã thêm logging chi tiết để debug:

**Backend** (`productService.js`):
- Log khi create/update/delete product
- Log product ID đang tìm kiếm
- Log danh sách products nếu không tìm thấy
- Clear cache sau mỗi thao tác

**Flutter**:
- Log product ID gốc và đã encode
- Log URL đầy đủ
- Log response status và body

### 4. Cache Management
Clear cache sau mỗi thao tác CRUD để đảm bảo data luôn fresh:
```javascript
// Clear cache after create/update/delete
this._productCache = {};
```

## Cách test
1. Restart backend server (để áp dụng code mới)
2. Reload Flutter app
3. Đăng nhập admin
4. Vào "Quản lý sản phẩm"
5. Thử update một sản phẩm (toggle availability hoặc edit)
6. Kiểm tra console logs để thấy:
   - Flutter: Product ID được encode đúng
   - Backend: Product ID được decode và tìm thấy

## Files đã sửa

**Flutter:**
- `lib/services/api_service.dart` - Add URL encoding
- `lib/providers/product_provider.dart` - Add debug logging

**Backend:**
- `backend/src/routes/admin.js` - Add URL decoding
- `backend/src/services/productService.js` - Add logging & cache clearing

## Kiến thức bổ sung

### URL Encoding
Ký tự cần encode trong URL:
- `#` → `%23` (fragment identifier)
- `?` → `%3F` (query string)
- `&` → `%26` (parameter separator)
- `%` → `%25` (escape character)
- `/` → `%2F` (path separator)
- Spaces → `%20` hoặc `+`

### Best Practices
1. **Luôn encode URL parameters** khi chứa user input
2. **Decode ngay khi nhận** ở server side
3. **Log debug info** khi có vấn đề
4. **Clear cache** sau các thao tác thay đổi data


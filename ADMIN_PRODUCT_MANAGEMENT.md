# Tài liệu Quản lý Sản phẩm Admin

## Tổng quan
Đã thêm đầy đủ chức năng admin quản lý sản phẩm cho ứng dụng Highlands Coffee.

## Chức năng đã thực hiện

### 1. Backend API (Đã có sẵn)
Backend đã có đầy đủ các API endpoint cần thiết:

- **POST** `/api/admin/products` - Tạo sản phẩm mới
- **PUT** `/api/admin/products/:productId` - Cập nhật sản phẩm
- **DELETE** `/api/admin/products/:productId` - Xóa sản phẩm

#### Validation
- Đơn hàng tự động kiểm tra `isAvailable` khi tạo (orderService.js:131-133)
- Giỏ hàng kiểm tra `isAvailable` khi thêm sản phẩm (cart.js:47-51)

### 2. Flutter - Admin Panel

#### Màn hình quản lý sản phẩm (`lib/screens/admin/admin_products_screen.dart`)
Tính năng:
- ✅ Xem danh sách tất cả sản phẩm
- ✅ Thêm sản phẩm mới
- ✅ Chỉnh sửa sản phẩm (tên, mô tả, giá, hình ảnh, danh mục)
- ✅ Xóa sản phẩm
- ✅ Bật/tắt trạng thái bán hàng (toggle `isAvailable`)
- ✅ UI hiển thị rõ ràng trạng thái "Đang bán" / "Tạm ngưng"

#### API Service (`lib/services/api_service.dart`)
Đã thêm các method:
```dart
Future<Product> createProduct(Map<String, dynamic> productData)
Future<Product> updateProduct(String productId, Map<String, dynamic> updates)
Future<void> deleteProduct(String productId)
```

#### Product Provider (`lib/providers/product_provider.dart`)
Đã thêm các method:
```dart
Future<void> createProduct(Map<String, dynamic> productData)
Future<void> updateProduct(String productId, Map<String, dynamic> updates)
Future<void> deleteProduct(String productId)
```

### 3. Giao diện người dùng

#### Home Screen (`lib/screens/home/home_screen.dart`)
- ✅ Hiển thị badge "Tạm ngưng" cho sản phẩm không available
- ✅ Overlay "TẠM HẾT" trên hình ảnh sản phẩm
- ✅ Text màu xám cho sản phẩm không available
- ✅ Menu admin với "Quản lý sản phẩm" và "Quản lý đơn hàng"

#### Product Detail Screen (`lib/screens/product/product_detail_screen.dart`)
- ✅ Overlay "TẠM NGƯNG BÁN" trên hình ảnh
- ✅ Nút "Thêm vào giỏ" bị disable khi sản phẩm không available
- ✅ Validation ngăn thêm sản phẩm không available vào giỏ
- ✅ Thông báo lỗi khi cố thêm sản phẩm tạm ngưng

### 4. Navigation

Đã thêm route trong `lib/main.dart`:
```dart
'/admin/products': (context) => const AdminProductsScreen()
```

## Cách sử dụng

### Đối với Admin:
1. Đăng nhập với tài khoản admin (email: `admin@highlands.vn`)
2. Mở menu bên trái, chọn "Quản lý sản phẩm" trong mục "QUẢN TRỊ"
3. Trong màn hình quản lý sản phẩm:
   - **Thêm sản phẩm**: Nhấn nút FAB (+) ở góc dưới bên phải
   - **Chỉnh sửa giá**: Nhấn menu 3 chấm → "Chỉnh sửa"
   - **Tạm ngưng bán**: Nhấn menu 3 chấm → "Tạm ngưng bán"
   - **Mở bán lại**: Nhấn menu 3 chấm → "Mở bán lại"
   - **Xóa sản phẩm**: Nhấn menu 3 chấm → "Xóa"

### Đối với người dùng thường:
- Sản phẩm tạm ngưng sẽ hiển thị với:
  - Badge "Tạm ngưng" màu đỏ
  - Overlay "TẠM HẾT" trên hình ảnh
  - Text màu xám
  - Không thể thêm vào giỏ hàng

## Bảo mật
- Tất cả API admin yêu cầu authentication token
- Middleware `authMiddleware` kiểm tra quyền admin (có thể bật lại tại admin.js:13)
- Chỉ user có `role === 'admin'` mới thấy menu quản trị

## Database
Sản phẩm được lưu trong Bigtable với các field:
- `name`: Tên sản phẩm
- `description`: Mô tả
- `price`: Giá (VND)
- `imageUrl`: URL hình ảnh
- `category`: Danh mục (coffee, tea, freeze, food, pastry, merchandise)
- `isAvailable`: Trạng thái bán hàng (true/false) ⭐
- `sizes`: Danh sách size (JSON)
- `options`: Các tùy chọn (JSON)
- `preparationTime`: Thời gian chuẩn bị (phút)
- `rating`: Đánh giá trung bình
- `reviewCount`: Số lượt đánh giá

## Lưu ý
- Backend đã có validation, người dùng không thể đặt món đang tạm ngưng
- Flutter client cũng có validation ở nhiều lớp (UI + logic)
- Cache được cập nhật tự động sau mỗi thay đổi
- Admin có thể nhanh chóng toggle trạng thái available bằng menu 3 chấm

## Test
Để test chức năng:
1. Đăng nhập với tài khoản admin
2. Vào "Quản lý sản phẩm"
3. Chọn 1 sản phẩm → "Tạm ngưng bán"
4. Đăng xuất, đăng nhập với tài khoản user thường
5. Kiểm tra sản phẩm đó hiển thị "Tạm ngưng" và không thể thêm vào giỏ
6. Thử đặt hàng → Backend sẽ từ chối với lỗi "Product ... is not available"


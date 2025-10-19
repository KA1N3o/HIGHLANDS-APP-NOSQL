# 🚀 Quick Start Guide - Highlands Coffee App

## ⚡ Bắt đầu nhanh trong 5 phút

### Bước 1: Kiểm tra môi trường
```bash
flutter doctor
```
Đảm bảo tất cả ✓ đều xanh.

### Bước 2: Cài đặt dependencies
```bash
flutter pub get
```

### Bước 3: Chạy ứng dụng (Mock Data Mode)
```bash
flutter run
```

**Lưu ý**: Ứng dụng sẽ chạy với dữ liệu mẫu (mock data) mà không cần backend.

## 📱 Demo với Mock Data

App hiện đang sử dụng mock data service để bạn có thể test ngay mà không cần setup Bigtable:

### Dữ liệu mẫu có sẵn:
- ✅ 8 sản phẩm (cà phê, trà, smoothie, đồ ăn)
- ✅ 5 cửa hàng tại TP.HCM
- ✅ Giỏ hàng và thanh toán
- ✅ Theo dõi đơn hàng

### Tài khoản test:
Vì đang dùng mock data, bạn có thể login với bất kỳ email/password nào:
- Email: `test@test.com`
- Password: `123456`

## 🔧 Chuyển sang Production Mode

Khi đã sẵn sàng kết nối với Bigtable:

### 1. Tắt Mock Data Mode

Trong `lib/providers/product_provider.dart`:
```dart
bool _useMockData = false; // Đổi từ true sang false
```

Trong `lib/providers/store_provider.dart`:
```dart
bool _useMockData = false; // Đổi từ true sang false
```

### 2. Setup Bigtable Backend

```bash
cd bigtable
./setup.sh      # Tạo database (Linux/Mac)
./seed_data.sh  # Thêm dữ liệu mẫu
```

**Windows users**: Chạy các lệnh trong Git Bash hoặc WSL.

### 3. Cấu hình API URL

Trong `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://your-api-url.com/api';
```

### 4. Implement Backend API

Bạn cần tạo REST API server để kết nối Flutter app với Bigtable:
- Node.js + Express
- Python + FastAPI
- Go + Gin

Xem chi tiết trong `bigtable/README.md`

## 🎯 Tính năng chính để test

### 1. Trang chủ
- Xem danh sách sản phẩm
- Chuyển đổi giữa các danh mục
- Thêm vào giỏ hàng

### 2. Chi tiết sản phẩm
- Chọn size
- Chọn options (đường, đá, topping)
- Thêm ghi chú
- Điều chỉnh số lượng

### 3. Giỏ hàng
- Xem tổng quan đơn hàng
- Chỉnh sửa số lượng
- Xóa sản phẩm
- Tính tổng tiền + thuế

### 4. Chọn cửa hàng
- Xem danh sách cửa hàng
- Xem thông tin chi tiết
- Chọn cửa hàng nhận hàng

### 5. Thanh toán
- Chọn phương thức thanh toán
- Chọn thời gian nhận hàng
- Thêm ghi chú đơn hàng
- Xác nhận đặt hàng

### 6. Theo dõi đơn hàng
- Xem trạng thái realtime
- Chi tiết đơn hàng
- Lịch sử đơn hàng

## 🎨 Customize Theme

Trong `lib/config/theme.dart`, bạn có thể thay đổi:

```dart
static const Color primaryGreen = Color(0xFF006241);    // Màu chủ đạo
static const Color secondaryBrown = Color(0xFF8B4513);  // Màu phụ
static const Color accentOrange = Color(0xFFFF6B35);   // Màu nhấn
```

## 🔍 Debugging

### Xem logs
```bash
flutter run -v
```

### Hot reload
Nhấn `r` trong terminal để reload

### Hot restart
Nhấn `R` trong terminal để restart

### Clear cache
```bash
flutter clean
flutter pub get
flutter run
```

## 📦 Build APK

### Debug APK
```bash
flutter build apk --debug
```

### Release APK
```bash
flutter build apk --release
```

File APK sẽ có tại: `build/app/outputs/flutter-apk/`

## 🐛 Xử lý lỗi thường gặp

### Lỗi: "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Lỗi: "Unable to load asset"
Kiểm tra `pubspec.yaml` xem đã khai báo assets chưa:
```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
```

### Lỗi: "MissingPluginException"
```bash
flutter clean
flutter pub get
flutter run
```

### Lỗi kết nối mạng
Kiểm tra permissions trong:
- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist`

## 📱 Test trên thiết bị thật

### Android
1. Bật USB Debugging
2. Kết nối điện thoại
3. Chạy `flutter devices`
4. Chạy `flutter run`

### iOS
1. Mở Xcode
2. Thiết lập signing certificate
3. Kết nối iPhone
4. Chạy `flutter run`

## 🎓 Học thêm

### Flutter Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Go Router](https://pub.dev/packages/go_router)

### Highlands Coffee App
- `README.md` - Tổng quan dự án
- `bigtable/schema.md` - Schema database
- `bigtable/README.md` - Hướng dẫn Bigtable

## ❓ FAQ

**Q: Tôi có thể test app mà không cần setup Bigtable không?**  
A: Có! App đang chạy với mock data mặc định.

**Q: Mock data có giống thật không?**  
A: Mock data có cấu trúc giống hệt data thật, chỉ khác là lưu trong memory thay vì database.

**Q: Khi nào cần setup Bigtable?**  
A: Khi bạn muốn deploy production hoặc test với data thật từ nhiều users.

**Q: Chi phí Bigtable là bao nhiêu?**  
A: ~$470/tháng cho 1 node (development), ~$1,400/tháng cho 3 nodes (production). Dùng emulator miễn phí cho local dev.

**Q: Có thể dùng database khác không?**  
A: Có, bạn có thể thay Bigtable bằng Firebase, PostgreSQL, MongoDB... chỉ cần update API service.

## 🎉 Chúc bạn code vui vẻ!

Nếu có vấn đề, tạo issue trên GitHub hoặc liên hệ team.

Happy coding! ☕


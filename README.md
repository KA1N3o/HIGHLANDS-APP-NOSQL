# Highlands Coffee - Mobile Ordering App

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.8.1-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.8.1-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Google%20Bigtable-NoSQL-4285F4?logo=google-cloud" alt="Bigtable">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
</div>

## 📱 Giới thiệu

Highlands Coffee là ứng dụng đặt hàng di động cho chuỗi cà phê Highlands Coffee, giúp khách hàng:
- ☕ Đặt trước đồ uống yêu thích
- 💳 Thanh toán trực tuyến an toàn
- 🏪 Chọn cửa hàng nhận hàng gần nhất
- ⏰ Đặt lịch nhận hàng theo thời gian
- 📦 Nhận hàng nhanh chóng không cần xếp hàng

## ✨ Tính năng

### Khách hàng
- 🔐 Đăng ký/Đăng nhập tài khoản
- 🍵 Xem danh mục sản phẩm theo danh mục
- 🔍 Xem chi tiết sản phẩm với tùy chọn size và topping
- 🛒 Quản lý giỏ hàng
- 📍 Chọn cửa hàng nhận hàng
- 💰 Thanh toán qua nhiều phương thức (Thẻ, Tiền mặt, MoMo, ZaloPay)
- 📋 Theo dõi trạng thái đơn hàng realtime
- 📜 Xem lịch sử đơn hàng

### Quản lý (Staff/Admin)
- 📊 Quản lý đơn hàng theo trạng thái
- ✅ Xác nhận và cập nhật đơn hàng
- 🔔 Thông báo đơn hàng mới
- 📈 Theo dõi tiến độ chuẩn bị

## 🏗️ Kiến trúc

### Frontend
- **Framework**: Flutter 3.8.1
- **State Management**: Provider
- **Navigation**: Go Router
- **UI**: Material Design 3 với custom theme

### Backend
- **Database**: Google Cloud Bigtable (NoSQL)
- **Storage**: Hiệu suất cao, khả năng mở rộng tốt
- **API**: REST API (cần implement riêng)

### Cấu trúc thư mục
```
lib/
├── config/           # Cấu hình app (theme, constants)
├── models/           # Data models
│   ├── user.dart
│   ├── product.dart
│   ├── cart_item.dart
│   ├── store.dart
│   └── order.dart
├── providers/        # State management
│   ├── auth_provider.dart
│   ├── cart_provider.dart
│   ├── product_provider.dart
│   ├── store_provider.dart
│   └── order_provider.dart
├── services/         # API services
│   ├── api_service.dart
│   └── mock_data_service.dart
├── screens/          # UI screens
│   ├── auth/
│   ├── home/
│   ├── product/
│   ├── cart/
│   ├── store/
│   ├── checkout/
│   ├── order/
│   └── admin/
└── main.dart

bigtable/
├── schema.md         # Database schema documentation
├── setup.sh          # Setup script
├── seed_data.sh      # Sample data script
├── queries.sh        # Query examples
└── README.md         # Bigtable documentation
```

## 🚀 Cài đặt

### Yêu cầu
- Flutter SDK 3.8.1 trở lên
- Dart 3.8.1 trở lên
- Android Studio / Xcode (để chạy emulator)
- Google Cloud account (cho Bigtable)

### Bước 1: Clone repository
```bash
git clone https://github.com/your-repo/highlands.git
cd highlands
```

### Bước 2: Cài đặt dependencies
```bash
flutter pub get
```

### Bước 3: Setup Bigtable Backend
Xem hướng dẫn chi tiết trong `bigtable/README.md`

```bash
cd bigtable
chmod +x *.sh
./setup.sh      # Tạo database
./seed_data.sh  # Thêm dữ liệu mẫu
```

### Bước 4: Cấu hình API
Cập nhật URL API trong `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'YOUR_API_URL';
```

### Bước 5: Chạy ứng dụng
```bash
flutter run
```

## 🧪 Testing

### Tài khoản test
Sau khi chạy `seed_data.sh`, sử dụng:
- **Customer**: test@highlands.vn
- **Admin**: admin@highlands.vn
- **Password**: (cần implement trong API)

### Chạy test
```bash
flutter test
```

## 📦 Build

### Android
```bash
flutter build apk --release
# hoặc
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🎨 Theme & Branding

App sử dụng màu sắc thương hiệu Highlands Coffee:
- **Primary**: Green (#006241)
- **Secondary**: Brown (#8B4513)
- **Accent**: Orange (#FF6B35)

Fonts: Poppins (via Google Fonts)

## 📱 Screenshots

### Màn hình chính
- Danh sách sản phẩm theo danh mục
- Tìm kiếm và lọc sản phẩm
- Giỏ hàng nổi

### Chi tiết sản phẩm
- Hình ảnh sản phẩm
- Tùy chọn size và topping
- Ghi chú đặc biệt
- Thêm vào giỏ hàng

### Thanh toán
- Chọn cửa hàng
- Chọn thời gian nhận
- Chọn phương thức thanh toán
- Xác nhận đơn hàng

### Theo dõi đơn hàng
- Timeline trạng thái
- Thông tin chi tiết
- Cập nhật realtime

## 🔐 Bảo mật

- Mã hóa mật khẩu với bcrypt
- JWT token authentication
- HTTPS cho tất cả API calls
- Validation dữ liệu đầu vào
- Rate limiting trên API

## 🌐 API Endpoints

### Authentication
```
POST /api/auth/login
POST /api/auth/register
POST /api/auth/logout
```

### Products
```
GET  /api/products
GET  /api/products/:id
```

### Stores
```
GET  /api/stores
GET  /api/stores/:id
```

### Orders
```
POST /api/orders
GET  /api/orders/user/:userId
GET  /api/orders/:id
PATCH /api/orders/:id/status
```

### Payments
```
POST /api/payments
```

Chi tiết API spec cần được implement trong backend service.

## 🗄️ Database Schema

Xem chi tiết trong `bigtable/schema.md`

**Tables**:
- users
- products
- stores
- orders
- orders_by_user
- sessions

## 🔧 Troubleshooting

### Lỗi build
```bash
flutter clean
flutter pub get
flutter run
```

### Lỗi dependency
```bash
flutter pub upgrade
```

### Lỗi kết nối API
- Kiểm tra URL trong `api_service.dart`
- Đảm bảo backend đang chạy
- Kiểm tra network connectivity

## 📈 Roadmap

- [ ] Push notifications
- [ ] Loyalty program
- [ ] Voucher/Coupon system
- [ ] Store reviews and ratings
- [ ] Favorites products
- [ ] Order history analytics
- [ ] Social sharing
- [ ] Multiple languages

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Team

- **Developer**: Your Name
- **Designer**: Designer Name
- **Backend**: Backend Developer Name

## 📞 Support

- Email: support@highlands.vn
- Website: https://highlands.vn
- Phone: 1900-xxxx

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Google Cloud for Bigtable
- Highlands Coffee for inspiration
- Unsplash for product images

---

Made with ☕ and ❤️ by the Highlands Coffee team

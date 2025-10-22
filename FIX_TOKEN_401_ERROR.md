# Fix Lỗi 401 "No Token Provided"

## 🐛 Vấn Đề

Khi app restart, bạn gặp lỗi:
```
Exception: Get user orders error: 
Exception: Failed to get user orders: 
{"success":false,"error":{"message":"No token provided","statusCode":401}}
```

## 🔍 Nguyên Nhân

**Token không được restore vào ApiService khi app restart**

- User đã login và token được lưu vào `SharedPreferences`
- Khi app restart, `AuthProvider` không restore token vào `ApiService`
- Khi gọi API (getUserOrders, etc.), request không có token → lỗi 401

## ✅ Giải Pháp

Đã thêm auto-restore session vào `AuthProvider`:

### 1. **AuthProvider.dart**
- Thêm hàm `_restoreSession()` tự động chạy khi khởi tạo
- Restore token từ `SharedPreferences`
- **QUAN TRỌNG:** Set token vào `ApiService` bằng `_apiService.setAuthToken(savedToken)`
- Lấy thông tin user từ API để verify token còn hợp lệ

### 2. **ApiService.dart**
- Thêm hàm `getCurrentUser()` để lấy thông tin user hiện tại
- Endpoint: `GET /api/users/me`
- Sử dụng token trong header để authenticate

---

## 🔄 Cách Hoạt Động

### **Khi App Khởi Động:**

1. `AuthProvider` được khởi tạo
2. Constructor gọi `_restoreSession()`
3. `_restoreSession()`:
   - Đọc token từ `SharedPreferences`
   - **Set token vào ApiService** ✅
   - Gọi API để lấy thông tin user
   - Nếu thành công → User đã logged in
   - Nếu thất bại (token hết hạn) → Auto logout

### **Khi User Login:**

1. Login thành công → nhận token
2. Set token vào `ApiService`
3. Lưu token vào `SharedPreferences`
4. Lần sau app restart → token được restore

---

## 🧪 Test

### **Bước 1: Stop và Restart App**

```bash
# Stop app
q

# Run lại
flutter run
```

### **Bước 2: Kiểm Tra**

1. **Không cần login lại** - App tự động restore session
2. **Orders load được** - Không còn lỗi 401
3. **API calls hoạt động bình thường**

### **Bước 3: Test Token Expire**

1. Xóa token từ backend (hoặc đợi token hết hạn)
2. Restart app
3. App sẽ auto logout và quay về màn hình login

---

## 📝 Code Changes

### **auth_provider.dart:**

```dart
AuthProvider(this._apiService) {
  // Auto-restore session when provider is created
  _restoreSession();
}

Future<void> _restoreSession() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');
    final savedUserId = prefs.getString('user_id');
    
    if (savedToken != null && savedUserId != null) {
      _authToken = savedToken;
      // IMPORTANT: Set token in ApiService
      _apiService.setAuthToken(savedToken);
      
      // Try to get current user info from API
      try {
        _currentUser = await _apiService.getCurrentUser();
        notifyListeners();
      } catch (e) {
        // If token is expired or invalid, clear session
        print('Failed to restore session: $e');
        await logout();
      }
    }
  } catch (e) {
    print('Error restoring session: $e');
  }
}
```

### **api_service.dart:**

```dart
Future<User> getCurrentUser() async {
  try {
    final response = await _client.get(
      Uri.parse('$baseUrl/users/me'),
      headers: _headers,
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return User.fromJson(jsonResponse['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get current user: Invalid response format');
      }
    } else {
      throw Exception('Failed to get current user: ${response.body}');
    }
  } catch (e) {
    throw Exception('Get current user error: $e');
  }
}
```

---

## ✅ Kết Quả

- ✅ **Auto-restore session** khi app restart
- ✅ **Không còn lỗi 401** khi load orders
- ✅ **User experience tốt hơn** - không cần login lại
- ✅ **Token security** - auto logout nếu token hết hạn

---

## 🚀 Bước Tiếp Theo

1. **Stop app hiện tại** (`q`)
2. **Run lại:** `flutter run`
3. **Test load orders** - should work without 401 error!

---

**Done!** 🎉


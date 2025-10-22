# Hướng dẫn Gán Nhân viên cho Cửa hàng

## Tổng quan
Tính năng này cho phép Admin gán nhân viên (staff) quản lý một cửa hàng cụ thể. Nhân viên chỉ có thể xem và quản lý đơn hàng của cửa hàng được gán.

## Cách hoạt động

### 1. Phân quyền
- **Admin**: Xem tất cả cửa hàng, có dropdown để chọn cửa hàng
- **Staff (được gán store)**: Tự động xem cửa hàng được gán, không có dropdown
- **Staff (chưa gán store)**: Có dropdown chọn cửa hàng (tương tự admin)

### 2. Database Schema
User model đã được cập nhật với trường mới:
- `assignedStoreId` (String, nullable): ID của cửa hàng mà staff được gán

## Cách gán Staff cho Store

### Sử dụng Bigtable CLI

```bash
# Gán staff cho một cửa hàng
cbt -instance=highlands-dev set users staff_user_id profile:assignedStoreId=store_123
```

### Sử dụng PowerShell Script

```powershell
# Tạo file assign_staff_to_store.ps1
$env:BIGTABLE_EMULATOR_HOST = "localhost:8086"

# Thay đổi các giá trị này
$staffUserId = "user#abc123"  # ID của nhân viên
$storeId = "store#highland_distric1"  # ID của cửa hàng

# Execute
cbt -instance=highlands-dev -project=highlands set users $staffUserId "profile:assignedStoreId=$storeId"

Write-Host "✓ Đã gán staff $staffUserId cho store $storeId"
```

### API Endpoint (Cần implement)

```javascript
// PUT /api/admin/users/:userId/assign-store
{
  "storeId": "store#highland_district1"
}
```

## Testing

### 1. Tạo Staff Account
```powershell
# Tạo staff account mới
cbt -instance=highlands-dev set users "user#staff001" "profile:email=staff@highlands.vn" "profile:name=Staff Nguyen" "profile:phone=0901234567" "profile:role=staff" "profile:createdAt=2025-01-01T00:00:00Z"
```

### 2. Gán Staff cho Store
```powershell
# Gán staff cho cửa hàng District 1
cbt -instance=highlands-dev set users "user#staff001" "profile:assignedStoreId=store#highland_district1"
```

### 3. Verify
```powershell
# Xem thông tin staff
cbt -instance=highlands-dev read users "user#staff001"
```

## UI Behavior

### Admin Login
- Vào màn hình "Quản lý đơn hàng"
- Thấy dropdown "Chọn cửa hàng để xem đơn hàng"
- Có thể chọn bất kỳ cửa hàng nào

### Staff Login (Có assigned store)
- Vào màn hình "Quản lý đơn hàng"
- Thấy banner: "Cửa hàng của bạn: [Tên cửa hàng]"
- Không có dropdown, không thể đổi cửa hàng
- Tự động load đơn hàng của cửa hàng được gán

### Staff Login (Chưa có assigned store)
- Vào màn hình "Quản lý đơn hàng"
- Thấy dropdown "Chọn cửa hàng để xem đơn hàng"
- Có thể chọn cửa hàng (tương tự admin)

## File Changes

### Frontend
- `lib/models/user.dart`: Thêm `assignedStoreId` field
- `lib/screens/admin/admin_orders_screen.dart`: Logic hiển thị dropdown theo role

### Backend
- `backend/src/models/User.js`: Thêm `assignedStoreId` field
- `backend/src/routes/admin.js`: (Cần thêm) Endpoint gán staff cho store

## Next Steps

### 1. Tạo Admin UI để gán Staff
Tạo màn hình trong admin panel:
- Danh sách staff
- Dropdown chọn cửa hàng cho mỗi staff
- Button "Lưu" để update assignedStoreId

### 2. Backend API Endpoint
```javascript
// backend/src/routes/admin.js
router.put('/users/:userId/assign-store', adminMiddleware, async (req, res) => {
  const { userId } = req.params;
  const { storeId } = req.body;
  
  await userService.updateUser(userId, { assignedStoreId: storeId });
  
  res.json({ success: true, message: 'Staff assigned to store successfully' });
});
```

### 3. Validation
- Chỉ admin mới có thể gán staff
- Validate storeId tồn tại
- Validate userId là staff role

## Notes
- Staff chỉ xem được đơn hàng của 1 cửa hàng duy nhất
- Admin luôn xem được tất cả
- assignedStoreId = null nghĩa là chưa được gán (staff có thể chọn tất cả)



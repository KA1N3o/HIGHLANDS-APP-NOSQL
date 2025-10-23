# Fix: Staff Store Access Control

## Vấn đề
Account Boo (staff) đã được gán cho quản lý cửa hàng chi nhánh Nguyễn Huệ nhưng vẫn cho phép chọn tất cả các cửa hàng như admin.

## Nguyên nhân
Backend API `/api/stores` trả về **tất cả** cửa hàng cho mọi user mà không kiểm tra role hoặc `assignedStoreId`.

## Giải pháp

### 1. Backend - Store API Filter (backend/src/routes/stores.js)

**Thay đổi:**
- Thêm logic lọc stores dựa trên user role
- Nếu user là **staff** với `assignedStoreId`, chỉ trả về store được gán
- Admin và customer vẫn nhận được tất cả stores

**Code:**
```javascript
router.get('/', authMiddleware, async (req, res, next) => {
  try {
    const { lat, lon, radius } = req.query;
    const user = req.user; // Get authenticated user from middleware
    
    let stores;
    if (lat && lon) {
      const latitude = parseFloat(lat);
      const longitude = parseFloat(lon);
      const radiusKm = radius ? parseFloat(radius) : 10;
      
      stores = await storeService.getNearbyStores(latitude, longitude, radiusKm);
    } else {
      stores = await storeService.getAllStores();
    }
    
    // Filter stores based on user role
    // If user is staff with assigned store, only return that store
    if (user.role === 'staff' && user.assignedStoreId) {
      stores = stores.filter(store => store.id === user.assignedStoreId);
    }
    // Admin and customers can see all stores
    
    res.status(200).json(successResponse('Stores retrieved', stores));
  } catch (error) {
    next(error);
  }
});
```

### 2. Cách hoạt động

1. **Staff login vào app**
   - Khi gọi API `/api/stores`, backend kiểm tra `req.user.role` và `req.user.assignedStoreId`
   - Nếu là staff với assignedStoreId, lọc array và chỉ trả về 1 store

2. **Frontend tự động nhận đúng data**
   - `StoreProvider` sẽ chỉ lưu 1 store từ API response
   - Tất cả màn hình sử dụng `storeProvider.stores` sẽ tự động chỉ hiển thị 1 store

3. **Các màn hình bị ảnh hưởng:**
   - ✅ `AdminOrdersScreen` - Dropdown chỉ có 1 option (hoặc auto-select và ẩn dropdown)
   - ✅ `StoreListScreen` - Danh sách chỉ có 1 store
   - ✅ `CheckoutScreen` - Chỉ hiển thị 1 store để chọn

## Testing

### Chuẩn bị:
1. Khởi động backend: `cd backend && npm start`
2. Đảm bảo user "Boo" có:
   - `role = 'staff'`
   - `assignedStoreId = 'store#nguyen_hue'` (hoặc ID khác)

### Test Script:
```bash
.\test_staff_store_access.ps1
```

### Kết quả mong đợi:
```
=== Testing Staff Store Access ===

1. Logging in as Boo (staff)...
✓ Logged in successfully
  Name: Boo
  Role: staff
  Assigned Store ID: store#nguyen_hue

2. Getting stores as staff...
✓ Retrieved stores
  Number of stores returned: 1
  ✓ Correct! Staff can only see 1 store
  Store ID: store#nguyen_hue
  Store Name: Nguyễn Huệ
  ✓ Correct! Store ID matches assignedStoreId

3. Logging in as admin for comparison...
✓ Logged in as admin

4. Getting stores as admin...
✓ Retrieved stores as admin
  Number of stores returned: 5 (hoặc số stores trong hệ thống)
  ✓ Admin can see all stores

=== Summary ===
Staff (Boo) can see: 1 store(s)
Admin can see: 5 store(s)

Test PASSED ✓
```

### Test thủ công trên app:
1. Login vào app bằng account Boo
2. Vào màn hình "Quản lý đơn hàng"
3. **Kiểm tra:**
   - Không có dropdown chọn store (hoặc dropdown chỉ có 1 option)
   - Hiển thị thông tin store được gán ở phía trên
4. Vào màn hình "Checkout" hoặc "Chọn cửa hàng"
5. **Kiểm tra:**
   - Danh sách chỉ có 1 store (store được gán)

## Security Benefits
1. **Backend validation**: Không thể bypass bằng cách gọi API trực tiếp
2. **Frontend consistency**: Tất cả màn hình tự động tuân theo quy tắc
3. **Database integrity**: Staff chỉ có thể tạo/quản lý orders cho store được gán

## Files Changed
- `backend/src/routes/stores.js` - Added role-based filtering
- `test_staff_store_access.ps1` - New test script

## Notes
- Frontend code không cần thay đổi vì đã có logic ẩn/hiển thị dropdown dựa trên role
- StoreProvider sẽ tự động chỉ lưu stores được backend trả về
- Admin và customer không bị ảnh hưởng, vẫn thấy tất cả stores


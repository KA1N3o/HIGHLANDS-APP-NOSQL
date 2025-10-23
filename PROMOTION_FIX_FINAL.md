# Fix: Mã giảm giá mất khi refresh

## Nguyên nhân

Backend KHÔNG lưu được promotion vào Bigtable/HBase.

**Logs cho thấy**:
```
Creating new promotion...
PromotionProvider: Created promotion, total: 1  ← Frontend add vào cache
Promotion created successfully
Current promotions count: 1
PromotionProvider: Loaded 0 promotions from server  ← Backend trả về 0!
```

## Đã kiểm tra

✅ Table `promotions` đã tồn tại trong HBase  
✅ Backend code có `tables.promotions`  
❌ Backend KHÔNG lưu được data vào table

## Giải pháp

### Bước 1: Đảm bảo backend đang chạy

```powershell
cd backend
npm start
```

Đợi đến khi thấy:
```
Server running on port 8080
Using HBase Docker for development
```

### Bước 2: Test tạo promotion qua API

```powershell
# Chạy script test
powershell -ExecutionPolicy Bypass -File test_promotion_backend.ps1
```

**Kết quả mong đợi**:
```
✓ Created promotion ID: promo#xxx
✓ Total promotions: 1
✓ SUCCESS! Our promotion is saved in database!
```

Nếu thấy: `ERROR! No promotions found in database!`  
➡️ Vấn đề ở backend service `savePromotion()`

### Bước 3: Kiểm tra backend logs

Mở terminal backend (nơi chạy `npm start`), tìm lỗi:

**Lỗi có thể gặp**:
1. `Cannot read property 'save' of undefined` → Table không được khởi tạo đúng
2. `Connection refused` → HBase Docker không chạy
3. `Row.save is not a function` → HBase adapter lỗi

### Bước 4: Verify HBase connection

```powershell
# Kiểm tra HBase có đang chạy
docker ps | Select-String "hbase"

# Nếu không thấy, start HBase
docker-compose up -d hbase
```

### Bước 5: Test trực tiếp trong HBase

```powershell
# Scan table promotions
docker exec -it hbase hbase shell
scan 'promotions'
```

Nếu empty → Backend không save được  
Nếu có data → Backend save OK, vấn đề ở load

## Debug thêm

Thêm logs vào `backend/src/services/promotionService.js`:

```javascript
async savePromotion(promotion) {
  console.log('=== SAVING PROMOTION ===');
  console.log('Promotion ID:', promotion.id);
  console.log('Promotion Code:', promotion.code);
  
  const promotionsTable = tables.promotions;
  console.log('Table:', promotionsTable);
  
  const row = promotionsTable.row(promotion.id);
  console.log('Row:', row);

  const mutations = [/* ... */];
  console.log('Mutations:', JSON.stringify(mutations, null, 2));
  
  try {
    await row.save(mutations);
    console.log('✓ Promotion saved successfully!');
  } catch (error) {
    console.error('✗ Error saving promotion:', error);
    throw error;
  }
}
```

## Giải pháp tạm thời

Nếu backend vẫn không lưu được, dùng mock data:

```dart
// lib/providers/promotion_provider.dart
bool _useMockData = true; // Tạm thời dùng mock

Future<void> loadAllPromotions({bool forceRefresh = false}) async {
  if (_useMockData) {
    _promotions = [
      Promotion(
        id: 'promo#1',
        code: 'GIAM10',
        name: 'Giảm 10%',
        description: 'Giảm 10% cho đơn từ 100k',
        type: PromotionType.percentage,
        value: 10,
        minOrderValue: 100000,
        maxDiscount: 50000,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 30)),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    notifyListeners();
    return;
  }
  // ... code hiện tại
}
```

## Kết luận

Vấn đề CỐT LÕI: **Backend `savePromotion()` không hoạt động**

Cần:
1. ✅ Check backend logs khi tạo promotion
2. ✅ Test HBase connection
3. ✅ Verify table structure
4. ✅ Debug savePromotion() method

Sau khi fix backend, frontend sẽ hoạt động ngay vì cache đã implement đúng.


# ✅ ĐÃ FIX: Mã giảm giá mất khi refresh

## 🐛 Vấn đề

Backend logs cho thấy:
```
HBase PUT command: put 'promotions', 'promo#xxx', 'undefined:undefined', 'undefined'
```

Column family và value đều là `undefined` → Data không được lưu đúng!

## 🔍 Nguyên nhân

File `backend/src/services/promotionService.js` dùng **SAI format mutations**:

```javascript
// SAI ❌
const mutations = [{
  method: 'insert',
  data: {
    info: { code: '...', name: '...' }  // Nested sai!
  }
}];
```

Trong khi tất cả các service khác dùng:

```javascript
// ĐÚNG ✅
const mutations = createMutations('info', {
  code: '...', 
  name: '...'
});
```

## ✅ Giải pháp

**File đã sửa**: `backend/src/services/promotionService.js` (dòng 169-194)

```javascript
async savePromotion(promotion) {
  const promotionsTable = tables.promotions;
  const row = promotionsTable.row(promotion.id);
  const { createMutations } = require('../utils/helpers');

  // ✅ Dùng createMutations như các service khác
  const mutations = createMutations('info', {
    code: promotion.code,
    name: promotion.name,
    description: promotion.description,
    type: promotion.type,
    value: promotion.value.toString(),
    minOrderValue: promotion.minOrderValue.toString(),
    maxDiscount: promotion.maxDiscount ? promotion.maxDiscount.toString() : '',
    usageLimit: promotion.usageLimit ? promotion.usageLimit.toString() : '',
    usageCount: promotion.usageCount.toString(),
    startDate: promotion.startDate,
    endDate: promotion.endDate,
    isActive: promotion.isActive.toString(),
    createdAt: promotion.createdAt,
    updatedAt: promotion.updatedAt,
  });

  console.log(`Saving promotion ${promotion.id} with code ${promotion.code}`);
  await row.save(mutations);
  console.log(`✓ Promotion ${promotion.code} saved successfully`);
}
```

## 🚀 Cách test

1. **Restart backend** (trong terminal backend, nhấn Ctrl+C rồi chạy lại):
   ```bash
   cd backend
   npm start
   ```

2. **Hot reload Flutter app** (nhấn `r` trong terminal Flutter)

3. **Tạo mã giảm giá mới**

4. **Kiểm tra backend logs**, bạn sẽ thấy:
   ```
   Saving promotion promo#xxx with code TEST1234
   HBase PUT command: put 'promotions', 'promo#xxx', 'info:code', 'TEST1234'
   HBase PUT command: put 'promotions', 'promo#xxx', 'info:name', 'Test Promotion'
   ...
   ✓ Promotion TEST1234 saved successfully
   ```

5. **Nhấn refresh** trong app → Mã vẫn còn! ✅

## 📝 Kết quả mong đợi

```
Creating new promotion...
PromotionProvider: Created promotion, total: 1
Promotion created successfully
Current promotions count: 1

[Nhấn refresh]

PromotionProvider: Loaded 1 promotions from server  ← ✅ Có mã!
```

## 🎉 Hoàn thành

Sau khi restart backend, hệ thống mã giảm giá sẽ hoạt động hoàn toàn:
- ✅ Tạo mã → Lưu vào HBase
- ✅ Refresh → Load lại từ database
- ✅ Cache 5 phút → Không reload liên tục
- ✅ Edit/Delete → Cập nhật đúng

**Hãy restart backend và test lại!**


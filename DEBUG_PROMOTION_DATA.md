# Debug: Promotion Data Parse Issue

## Vấn đề

Frontend hiển thị "0%" cho tất cả mã giảm giá, mặc dù HBase đã lưu đúng data.

## Data trong HBase (✅ Đúng)

```
column=info:code, value=FREESHIP
column=info:name, value=Highlands Free Shipping
column=info:type, value=free_shipping
column=info:value, value=0
column=info:minOrderValue, value=0
column=info:isActive, value=true
```

## Cách debug

### Bước 1: Restart backend với debug logs

```bash
# Terminal backend
Ctrl+C
npm start
```

### Bước 2: Hot reload Flutter app

```bash
# Terminal Flutter
r
```

### Bước 3: Load promotions và xem logs

1. Vào "Quản lý mã giảm giá"
2. Nhấn refresh (icon refresh)
3. Xem **backend terminal**, bạn sẽ thấy:

```
Got 1 promotion rows from HBase
Parsed promotion data: {
  "code": "FREESHIP",
  "name": "Highlands Free Shipping",
  "type": "free_shipping",
  "value": "0",
  ...
}
Created promotion: {
  "code": "FREESHIP",
  "name": "Highlands Free Shipping",
  "type": "free_shipping",
  "value": 0,
  ...
}
```

### Bước 4: Kiểm tra type

Xem field `"type"` có đúng là `"free_shipping"` không?

**Nếu type sai** → Backend parse sai type  
**Nếu type đúng** → Frontend parse sai

## Có thể nguyên nhân

### 1. Backend parse sai type

File `backend/src/models/Promotion.js` - `fromBigtableRow()`:

```javascript
type: parsedData.type || 'percentage',
```

Nếu `parsedData.type` là string rỗng → default về 'percentage'

### 2. Value bị parse sai

Value trong HBase là string "0", cần parse thành number:

```javascript
value: parseFloat(parsedData.value) || 0,
```

### 3. Frontend không nhận đúng type

Flutter model parse type từ string:

```dart
case 'free_shipping':
  return PromotionType.freeShipping;
```

## Quick Test

Tạo mã mới với:
- Type: Phần trăm (percentage)
- Value: 10

Xem có hiển thị "10%" không?

**Nếu hiển thị "10%"** → Vấn đề chỉ với type free_shipping  
**Nếu vẫn "0%"** → Vấn đề nghiêm trọng hơn

## Gửi backend logs

Sau khi restart backend và nhấn refresh, **copy toàn bộ logs từ "Got X promotion rows"** và gửi cho tôi để debug tiếp.

## Tạm thời workaround

Nếu chỉ cần test, có thể sửa displayValue:

```dart
String get displayValue {
  switch (type) {
    case PromotionType.percentage:
      return value > 0 ? '${value.toStringAsFixed(0)}%' : 'N/A';
    case PromotionType.fixedAmount:
      return value > 0 ? '${value.toStringAsFixed(0)}đ' : 'N/A';
    case PromotionType.freeShipping:
      return 'Miễn phí ship';  // ← Luôn hiển thị text này
  }
}
```


# Hướng dẫn sử dụng Topping System

## Các loại topping có sẵn

| Topping | Giá | Mô tả |
|---------|-----|-------|
| Hạt Sen | 10,000₫ | Hạt sen tươi, bổ dưỡng |
| Củ Năng | 10,000₫ | Củ năng giòn, ngọt thanh |
| Thạch Đào | 10,000₫ | Thạch đào mềm mịn, thơm ngon |
| Thạch Vải | 10,000₫ | Thạch vải thanh mát |
| Thạch Trà / Thạch Sô-cô-la | 10,000₫ | Thạch trà hoặc socola đậm đà |
| Trân Châu Dừa | 10,000₫ | Trân châu dừa dai ngon |
| Trân Châu Khoai Môn | 10,000₫ | Trân châu khoai môn thơm béo |
| Kem Whip (Kem tươi) | 15,000₫ | Kem tươi béo ngậy |

## Cách thêm topping vào sản phẩm

### Bước 1: Đảm bảo backend đang chạy
```powershell
cd backend
npm start
```

### Bước 2: Chạy script thêm topping
```powershell
.\bigtable\add_toppings_to_products.ps1
```

Script này sẽ:
- Tự động thêm tất cả 8 loại topping vào các sản phẩm coffee, tea, và freeze
- Bỏ qua các sản phẩm food, pastry, và merchandise

### Bước 3: Kiểm tra kết quả
```powershell
.\test_toppings.ps1
```

## Cách thêm topping thủ công cho sản phẩm cụ thể

Sử dụng API PUT `/api/products/{productId}`:

```json
{
  "availableToppings": [
    {
      "id": "topping_hat_sen",
      "name": "Hạt Sen",
      "price": 10000,
      "imageUrl": "https://...",
      "isAvailable": true
    },
    {
      "id": "topping_kem_whip",
      "name": "Kem Whip (Kem tươi)",
      "price": 15000,
      "imageUrl": "https://...",
      "isAvailable": true
    }
  ]
}
```

## Cách topping hoạt động trong app

1. **Product Detail Screen**: Khách hàng có thể chọn nhiều topping bằng checkbox
2. **Giá tự động cập nhật**: Mỗi topping được chọn sẽ cộng thêm giá vào tổng
3. **Hiển thị trong giỏ hàng**: Topping được hiển thị với màu xanh để dễ phân biệt
4. **Lưu vào đơn hàng**: Topping được lưu cùng với thông tin sản phẩm

## Ví dụ tính giá

**Phin Sữa Đá - Size L**
- Giá cơ bản: 45,000₫
- Size L (×1.3): 58,500₫
- Trân Châu Dừa: +10,000₫
- Kem Whip: +15,000₫
- **Tổng: 83,500₫**

## Cấu trúc dữ liệu

### Trong Product model:
```javascript
{
  "id": "product#001",
  "name": "Phin Sữa Đá",
  "category": "coffee",
  "availableToppings": [
    {
      "id": "topping_hat_sen",
      "name": "Hạt Sen",
      "price": 10000,
      "isAvailable": true
    }
  ]
}
```

### Trong CartItem:
```javascript
{
  "product": {...},
  "size": "Large",
  "selectedToppings": [
    {
      "id": "topping_hat_sen",
      "name": "Hạt Sen",
      "price": 10000
    }
  ],
  "quantity": 2
}
```

## Lưu ý

- Topping chỉ áp dụng cho coffee, tea, và freeze (không áp dụng cho food, pastry, merchandise)
- Khách hàng có thể chọn nhiều topping cùng lúc
- Giá topping được cộng dồn, không nhân với số lượng sản phẩm (nếu mua 2 ly cùng topping thì tính 2 lần)
- Có thể tạm ngưng topping bằng cách set `isAvailable: false`


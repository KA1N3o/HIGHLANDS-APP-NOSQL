# Recreate Promotion AS

## Bước 1: Trong App Flutter

1. Hot restart app
2. Vào **Quản lý mã giảm giá**
3. Nếu thấy mã "AS", click menu (...) → Xóa
4. Nhấn **"Tạo mã giảm giá"**

## Bước 2: Nhập thông tin mới

### Thông tin cơ bản:
- **Mã giảm giá**: AS
- **Tên chương trình**: Ưu đãi AS
- **Mô tả**: Giảm giá cho khách hàng

### Loại & Giá trị:
- **Loại giảm giá**: Phần trăm
- **Giá trị (%)**: 10  (hoặc số bạn muốn)
- **Giới hạn giảm tối đa**: 50000đ (checkbox + nhập số)

### Điều kiện:
- **Giá trị đơn hàng tối thiểu**: 0 hoặc 30000 (QUAN TRỌNG: Phải <= 39000)
- **Giới hạn số lần sử dụng**: 100 (checkbox + nhập số)

### Thời gian:
- **Ngày bắt đầu**: Hôm nay hoặc ngày trong quá khứ
- **Ngày kết thúc**: Một ngày trong tương lai (ví dụ: 31/12/2025)

### Trạng thái:
- **Kích hoạt**: BẬT (ON)

## Bước 3: Lưu và test

1. Nhấn **"Lưu"**
2. Kiểm tra promotion hiển thị đầy đủ thông tin
3. Test áp dụng vào đơn hàng

## ⚠️ Lưu ý:

- **minOrderValue** phải <= 39,000đ để áp dụng được cho đơn hàng hiện tại
- **Ngày bắt đầu** phải <= hôm nay
- **Ngày kết thúc** phải >= hôm nay
- **Kích hoạt** phải BẬT



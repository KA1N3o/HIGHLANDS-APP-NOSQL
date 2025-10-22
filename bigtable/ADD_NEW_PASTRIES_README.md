# Thêm Bánh Ngọt Mới Vào Highlands Coffee

## 📋 Tổng Quan

Script này thêm 5 loại bánh ngọt mới vào danh mục "Bánh Ngọt" của Highlands Coffee:

1. **Bánh Su Kem** (pastry007) - 38,000₫
2. **Bánh Sữa Chua Phô Mai** (pastry008) - 45,000₫
3. **Bánh Phô Mai Trà Xanh** (pastry009) - 48,000₫
4. **Bánh Phô Mai Chanh Dây** (pastry010) - 48,000₫
5. **Mousse Cacao** (pastry011) - 52,000₫

**Lưu ý:** Bánh Tiramisu (pastry003) đã có sẵn trong hệ thống.

## 🚀 Cách Sử Dụng

### Phương Pháp 1: Sử Dụng PowerShell Script (Khuyến Nghị)

```powershell
# Chạy script PowerShell
.\add_new_pastries.ps1
```

Script sẽ:
- Tạo file lệnh HBase (`hbase_new_pastries.txt`)
- Kiểm tra xem HBase có khả dụng không
- Hỏi xác nhận trước khi thêm sản phẩm
- Tự động thêm các sản phẩm vào HBase

### Phương Pháp 2: Sử Dụng HBase Shell Trực Tiếp

```bash
# Khởi động HBase shell
hbase shell

# Chạy file lệnh
hbase shell hbase_new_pastries.txt
```

### Phương Pháp 3: Copy-Paste Thủ Công

1. Mở file `hbase_new_pastries.txt`
2. Khởi động HBase shell: `hbase shell`
3. Copy và paste từng lệnh vào shell

## 📝 Chi Tiết Sản Phẩm

### Bánh Su Kem (pastry007)
- **Giá:** 38,000₫
- **Mô tả:** Bánh su kem nhỏ xinh với nhân kem tươi béo ngậy, vỏ bánh giòn tan
- **Thời gian chuẩn bị:** 5 phút
- **Tùy chọn nhân:** Kem vani, Kem chocolate, Kem trà xanh

### Bánh Sữa Chua Phô Mai (pastry008)
- **Giá:** 45,000₫
- **Mô tả:** Bánh sữa chua phô mai mềm mịn, hương vị thanh mát, chua nhẹ
- **Thời gian chuẩn bị:** 5 phút
- **Topping:** Không, Quả mọng, Dâu tây

### Bánh Phô Mai Trà Xanh (pastry009)
- **Giá:** 48,000₫
- **Mô tả:** Cheesecake trà xanh matcha Nhật Bản, vị béo ngậy kết hợp hương trà đặc trưng
- **Thời gian chuẩn bị:** 5 phút
- **Topping:** Không, Whipped Cream, Red Bean

### Bánh Phô Mai Chanh Dây (pastry010)
- **Giá:** 48,000₫
- **Mô tả:** Cheesecake chanh dây nhiệt đới, vị chua ngọt hài hòa, thanh mát
- **Thời gian chuẩn bị:** 5 phút
- **Topping:** Không, Whipped Cream, Chanh dây tươi

### Mousse Cacao (pastry011)
- **Giá:** 52,000₫
- **Mô tả:** Mousse cacao nguyên chất, mềm mịn tan chảy, hương vị đậm đà
- **Thời gian chuẩn bị:** 5 phút
- **Topping:** Không, Whipped Cream, Chocolate Chips, Gold Leaf

## ✅ Kiểm Tra Sau Khi Thêm

Sau khi chạy script, bạn có thể kiểm tra xem sản phẩm đã được thêm thành công:

```bash
# Kiểm tra trong HBase
hbase shell

# Lấy thông tin một sản phẩm
get 'products', 'product#pastry007'

# Scan tất cả bánh ngọt
scan 'products', {FILTER => "PrefixFilter('product#pastry')"}
```

## 🔧 Yêu Cầu Hệ Thống

- HBase phải được cài đặt và chạy
- PowerShell (cho Windows) hoặc Bash (cho Linux/Mac)
- Bảng `products` phải tồn tại trong HBase

## 📊 Cập Nhật Tổng Quan

Sau khi thêm các sản phẩm này:
- **Tổng số sản phẩm:** 52 (tăng từ 47)
- **Số bánh ngọt:** 11 (tăng từ 6)
- **Giá cao nhất trong danh mục Đồ ăn:** 52,000₫ (Mousse Cacao)

## 📞 Hỗ Trợ

Nếu gặp vấn đề, vui lòng kiểm tra:
1. HBase đã chạy chưa
2. Bảng `products` đã được tạo chưa
3. Quyền truy cập vào HBase

---

**Tạo bởi:** Highlands Coffee Development Team  
**Ngày cập nhật:** 2024


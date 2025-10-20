#!/bin/bash

# Highlands Coffee - Local HBase Data Seeding Script
# Script này thêm dữ liệu mẫu vào HBase local

set -e

echo "========================================="
echo "Thêm dữ liệu mẫu vào HBase"
echo "========================================="
echo ""

# Tạo file HBase commands
cat > /tmp/hbase_seed_data.txt << 'EOF'
# ==================== PRODUCTS ====================
put 'products', 'product#p001', 'info:name', 'Phin Sữa Đá'
put 'products', 'product#p001', 'info:description', 'Cà phê phin truyền thống Việt Nam pha với sữa đặc'
put 'products', 'product#p001', 'info:price', '39000'
put 'products', 'product#p001', 'info:category', 'coffee'
put 'products', 'product#p001', 'info:isAvailable', 'true'
put 'products', 'product#p001', 'info:preparationTime', '8'
put 'products', 'product#p001', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#p001', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#p001', 'options:sizes', '["Small","Medium","Large"]'
put 'products', 'product#p001', 'options:options', '[{"name":"Đường","choices":["Ít","Vừa","Nhiều"]}]'

put 'products', 'product#p002', 'info:name', 'Bạc Xỉu'
put 'products', 'product#p002', 'info:description', 'Cà phê sữa nóng kiểu Việt Nam'
put 'products', 'product#p002', 'info:price', '39000'
put 'products', 'product#p002', 'info:category', 'coffee'
put 'products', 'product#p002', 'info:isAvailable', 'true'
put 'products', 'product#p002', 'info:preparationTime', '7'
put 'products', 'product#p002', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#p002', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#p002', 'options:sizes', '["Small","Medium","Large"]'
put 'products', 'product#p002', 'options:options', '[{"name":"Đường","choices":["Ít","Vừa","Nhiều"]}]'

put 'products', 'product#p003', 'info:name', 'Caramel Macchiato'
put 'products', 'product#p003', 'info:description', 'Espresso kết hợp với sữa tươi và caramel'
put 'products', 'product#p003', 'info:price', '55000'
put 'products', 'product#p003', 'info:category', 'coffee'
put 'products', 'product#p003', 'info:isAvailable', 'true'
put 'products', 'product#p003', 'info:preparationTime', '10'
put 'products', 'product#p003', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#p003', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#p003', 'options:sizes', '["Medium","Large"]'
put 'products', 'product#p003', 'options:options', '[{"name":"Topping","choices":["Không","Whipped Cream","Extra Caramel"]}]'

put 'products', 'product#p004', 'info:name', 'Cappuccino'
put 'products', 'product#p004', 'info:description', 'Cà phê Ý truyền thống với bọt sữa mịn'
put 'products', 'product#p004', 'info:price', '49000'
put 'products', 'product#p004', 'info:category', 'coffee'
put 'products', 'product#p004', 'info:isAvailable', 'true'
put 'products', 'product#p004', 'info:preparationTime', '8'
put 'products', 'product#p004', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#p004', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#p004', 'options:sizes', '["Small","Medium","Large"]'
put 'products', 'product#p004', 'options:options', '[{"name":"Shot","choices":["Single","Double"]}]'

put 'products', 'product#p005', 'info:name', 'Trà Đào Cam Sả'
put 'products', 'product#p005', 'info:description', 'Trà đen kết hợp với đào, cam và sả'
put 'products', 'product#p005', 'info:price', '49000'
put 'products', 'product#p005', 'info:category', 'tea'
put 'products', 'product#p005', 'info:isAvailable', 'true'
put 'products', 'product#p005', 'info:preparationTime', '12'
put 'products', 'product#p005', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#p005', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#p005', 'options:sizes', '["Medium","Large"]'
put 'products', 'product#p005', 'options:options', '[{"name":"Đường","choices":["Ít","Vừa","Nhiều"]}]'

put 'products', 'product#p006', 'info:name', 'Smoothie Xoài'
put 'products', 'product#p006', 'info:description', 'Sinh tố xoài tươi mát lạnh'
put 'products', 'product#p006', 'info:price', '59000'
put 'products', 'product#p006', 'info:category', 'smoothie'
put 'products', 'product#p006', 'info:isAvailable', 'true'
put 'products', 'product#p006', 'info:preparationTime', '10'
put 'products', 'product#p006', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#p006', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#p006', 'options:sizes', '["Medium","Large"]'
put 'products', 'product#p006', 'options:options', '[{"name":"Topping","choices":["Không","Thạch dừa","Trân châu"]}]'

put 'products', 'product#p007', 'info:name', 'Bánh Mì Pate'
put 'products', 'product#p007', 'info:description', 'Bánh mì Việt Nam với pate và thịt'
put 'products', 'product#p007', 'info:price', '32000'
put 'products', 'product#p007', 'info:category', 'food'
put 'products', 'product#p007', 'info:isAvailable', 'true'
put 'products', 'product#p007', 'info:preparationTime', '5'
put 'products', 'product#p007', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#p007', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#p007', 'options:sizes', '["Standard"]'
put 'products', 'product#p007', 'options:options', '[{"name":"Độ cay","choices":["Không cay","Ít cay","Cay vừa"]}]'

put 'products', 'product#p008', 'info:name', 'Bánh Croissant'
put 'products', 'product#p008', 'info:description', 'Bánh sừng bò bơ thơm giòn'
put 'products', 'product#p008', 'info:price', '35000'
put 'products', 'product#p008', 'info:category', 'pastry'
put 'products', 'product#p008', 'info:isAvailable', 'true'
put 'products', 'product#p008', 'info:preparationTime', '3'
put 'products', 'product#p008', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#p008', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#p008', 'options:sizes', '["Standard"]'
put 'products', 'product#p008', 'options:options', '[]'

# ==================== STORES ====================
put 'stores', 'store#s001', 'info:name', 'Highlands Coffee - Nguyễn Huệ'
put 'stores', 'store#s001', 'info:address', '123 Nguyễn Huệ, Q.1, TP.HCM'
put 'stores', 'store#s001', 'info:latitude', '10.7756'
put 'stores', 'store#s001', 'info:longitude', '106.7019'
put 'stores', 'store#s001', 'info:phone', '0901234567'
put 'stores', 'store#s001', 'info:isOpen', 'true'
put 'stores', 'store#s001', 'hours:openTime', '07:00'
put 'stores', 'store#s001', 'hours:closeTime', '22:00'

put 'stores', 'store#s002', 'info:name', 'Highlands Coffee - Lê Lợi'
put 'stores', 'store#s002', 'info:address', '456 Lê Lợi, Q.1, TP.HCM'
put 'stores', 'store#s002', 'info:latitude', '10.7727'
put 'stores', 'store#s002', 'info:longitude', '106.6988'
put 'stores', 'store#s002', 'info:phone', '0901234568'
put 'stores', 'store#s002', 'info:isOpen', 'true'
put 'stores', 'store#s002', 'hours:openTime', '07:00'
put 'stores', 'store#s002', 'hours:closeTime', '23:00'

put 'stores', 'store#s003', 'info:name', 'Highlands Coffee - Vincom Center'
put 'stores', 'store#s003', 'info:address', '72 Lê Thánh Tôn, Q.1, TP.HCM'
put 'stores', 'store#s003', 'info:latitude', '10.7797'
put 'stores', 'store#s003', 'info:longitude', '106.7011'
put 'stores', 'store#s003', 'info:phone', '0901234569'
put 'stores', 'store#s003', 'info:isOpen', 'true'
put 'stores', 'store#s003', 'hours:openTime', '08:00'
put 'stores', 'store#s003', 'hours:closeTime', '22:00'

put 'stores', 'store#s004', 'info:name', 'Highlands Coffee - Landmark 81'
put 'stores', 'store#s004', 'info:address', '720A Điện Biên Phủ, Bình Thạnh, TP.HCM'
put 'stores', 'store#s004', 'info:latitude', '10.7943'
put 'stores', 'store#s004', 'info:longitude', '106.7218'
put 'stores', 'store#s004', 'info:phone', '0901234570'
put 'stores', 'store#s004', 'info:isOpen', 'true'
put 'stores', 'store#s004', 'hours:openTime', '08:00'
put 'stores', 'store#s004', 'hours:closeTime', '22:00'

put 'stores', 'store#s005', 'info:name', 'Highlands Coffee - Crescent Mall'
put 'stores', 'store#s005', 'info:address', '101 Tôn Dật Tiên, Q.7, TP.HCM'
put 'stores', 'store#s005', 'info:latitude', '10.7285'
put 'stores', 'store#s005', 'info:longitude', '106.7198'
put 'stores', 'store#s005', 'info:phone', '0901234571'
put 'stores', 'store#s005', 'info:isOpen', 'true'
put 'stores', 'store#s005', 'hours:openTime', '08:00'
put 'stores', 'store#s005', 'hours:closeTime', '22:00'

# ==================== PROMOTIONS ====================
put 'promotions', 'promo#p001', 'info:code', 'HIGHLAND2024'
put 'promotions', 'promo#p001', 'info:name', 'Giảm giá đầu năm'
put 'promotions', 'promo#p001', 'info:description', 'Giảm 20% cho đơn hàng từ 100k'
put 'promotions', 'promo#p001', 'info:type', 'percentage'
put 'promotions', 'promo#p001', 'info:value', '20'
put 'promotions', 'promo#p001', 'info:minOrderValue', '100000'
put 'promotions', 'promo#p001', 'info:maxDiscount', '50000'
put 'promotions', 'promo#p001', 'info:usageLimit', '1000'
put 'promotions', 'promo#p001', 'info:usageCount', '0'
put 'promotions', 'promo#p001', 'info:startDate', '2024-01-01T00:00:00Z'
put 'promotions', 'promo#p001', 'info:endDate', '2024-12-31T23:59:59Z'
put 'promotions', 'promo#p001', 'info:isActive', 'true'
put 'promotions', 'promo#p001', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'promotions', 'promo#p001', 'info:updatedAt', '2024-01-01T00:00:00Z'

put 'promotions', 'promo#p002', 'info:code', 'FREESHIP'
put 'promotions', 'promo#p002', 'info:name', 'Miễn phí ship'
put 'promotions', 'promo#p002', 'info:description', 'Miễn phí giao hàng cho đơn từ 200k'
put 'promotions', 'promo#p002', 'info:type', 'free_shipping'
put 'promotions', 'promo#p002', 'info:value', '15000'
put 'promotions', 'promo#p002', 'info:minOrderValue', '200000'
put 'promotions', 'promo#p002', 'info:maxDiscount', '15000'
put 'promotions', 'promo#p002', 'info:usageLimit', '500'
put 'promotions', 'promo#p002', 'info:usageCount', '0'
put 'promotions', 'promo#p002', 'info:startDate', '2024-01-01T00:00:00Z'
put 'promotions', 'promo#p002', 'info:endDate', '2024-12-31T23:59:59Z'
put 'promotions', 'promo#p002', 'info:isActive', 'true'
put 'promotions', 'promo#p002', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'promotions', 'promo#p002', 'info:updatedAt', '2024-01-01T00:00:00Z'

put 'promotions', 'promo#p003', 'info:code', 'NEWUSER50'
put 'promotions', 'promo#p003', 'info:name', 'Khách hàng mới'
put 'promotions', 'promo#p003', 'info:description', 'Giảm 50k cho đơn đầu tiên'
put 'promotions', 'promo#p003', 'info:type', 'fixed_amount'
put 'promotions', 'promo#p003', 'info:value', '50000'
put 'promotions', 'promo#p003', 'info:minOrderValue', '150000'
put 'promotions', 'promo#p003', 'info:maxDiscount', '50000'
put 'promotions', 'promo#p003', 'info:usageLimit', '100'
put 'promotions', 'promo#p003', 'info:usageCount', '0'
put 'promotions', 'promo#p003', 'info:startDate', '2024-01-01T00:00:00Z'
put 'promotions', 'promo#p003', 'info:endDate', '2024-12-31T23:59:59Z'
put 'promotions', 'promo#p003', 'info:isActive', 'true'
put 'promotions', 'promo#p003', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'promotions', 'promo#p003', 'info:updatedAt', '2024-01-01T00:00:00Z'

EOF

echo "Đang thêm dữ liệu vào HBase..."
echo ""

# Chạy HBase shell với file commands
hbase shell /tmp/hbase_seed_data.txt

# Xóa file tạm
rm /tmp/hbase_seed_data.txt

echo ""
echo "========================================="
echo "✅ Thêm dữ liệu hoàn tất!"
echo "========================================="
echo ""
echo "Dữ liệu đã thêm:"
echo "  ✓ 8 sản phẩm (coffee, tea, smoothie, food, pastry)"
echo "  ✓ 5 cửa hàng tại TP.HCM"
echo "  ✓ 3 mã khuyến mãi"
echo ""
echo "Kiểm tra dữ liệu:"
echo "  hbase shell"
echo "  > scan 'products', {LIMIT => 5}"
echo "  > scan 'stores'"
echo "  > scan 'promotions'"
echo "  > get 'products', 'product#p001'"
echo ""
echo "Bạn có thể bắt đầu test API ngay bây giờ!"
echo ""







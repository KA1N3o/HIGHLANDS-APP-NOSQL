#!/bin/bash

# Highlands Coffee - Food & Merchandise Products
# Script thêm đồ ăn và sản phẩm đóng gói

set -e

echo "========================================="
echo "Thêm đồ ăn và merchandise vào HBase"
echo "========================================="
echo ""

cat > /tmp/hbase_food_merchandise.txt << 'EOF'
# ==================== THỨC ĂN (FOOD) ====================
put 'products', 'product#food001', 'info:name', 'Bánh Mì Que Bò Phô Mai'
put 'products', 'product#food001', 'info:description', 'Bánh mì que giòn với nhân bò sốt phô mai béo ngậy'
put 'products', 'product#food001', 'info:price', '35000'
put 'products', 'product#food001', 'info:category', 'food'
put 'products', 'product#food001', 'info:isAvailable', 'true'
put 'products', 'product#food001', 'info:preparationTime', '5'
put 'products', 'product#food001', 'info:imageUrl', 'https://images.unsplash.com/photo-1509440159596-0249088772ff'
put 'products', 'product#food001', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#food001', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#food001', 'options:sizes', '["Standard"]'
put 'products', 'product#food001', 'options:options', '[]'

put 'products', 'product#food002', 'info:name', 'Bánh Mì Que Gà Phô Mai'
put 'products', 'product#food002', 'info:description', 'Bánh mì que giòn với nhân gà phô mai thơm ngon'
put 'products', 'product#food002', 'info:price', '35000'
put 'products', 'product#food002', 'info:category', 'food'
put 'products', 'product#food002', 'info:isAvailable', 'true'
put 'products', 'product#food002', 'info:preparationTime', '5'
put 'products', 'product#food002', 'info:imageUrl', 'https://images.unsplash.com/photo-1509440159596-0249088772ff'
put 'products', 'product#food002', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#food002', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#food002', 'options:sizes', '["Standard"]'
put 'products', 'product#food002', 'options:options', '[]'

put 'products', 'product#food003', 'info:name', 'Bánh Mì Que Pate'
put 'products', 'product#food003', 'info:description', 'Bánh mì que với pate đặc biệt'
put 'products', 'product#food003', 'info:price', '32000'
put 'products', 'product#food003', 'info:category', 'food'
put 'products', 'product#food003', 'info:isAvailable', 'true'
put 'products', 'product#food003', 'info:preparationTime', '5'
put 'products', 'product#food003', 'info:imageUrl', 'https://images.unsplash.com/photo-1509440159596-0249088772ff'
put 'products', 'product#food003', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#food003', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#food003', 'options:sizes', '["Standard"]'
put 'products', 'product#food003', 'options:options', '[]'

# ==================== BÁNH NGỌT (PASTRY) ====================
put 'products', 'product#pastry001', 'info:name', 'Croissant Bơ'
put 'products', 'product#pastry001', 'info:description', 'Bánh sừng bò bơ Pháp giòn tan thơm ngon'
put 'products', 'product#pastry001', 'info:price', '35000'
put 'products', 'product#pastry001', 'info:category', 'pastry'
put 'products', 'product#pastry001', 'info:isAvailable', 'true'
put 'products', 'product#pastry001', 'info:preparationTime', '3'
put 'products', 'product#pastry001', 'info:imageUrl', 'https://images.unsplash.com/photo-1555507036-ab1f4038808a'
put 'products', 'product#pastry001', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry001', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry001', 'options:sizes', '["Standard"]'
put 'products', 'product#pastry001', 'options:options', '[]'

put 'products', 'product#pastry002', 'info:name', 'Croissant Chocolate'
put 'products', 'product#pastry002', 'info:description', 'Bánh sừng bò nhân chocolate đậm đà'
put 'products', 'product#pastry002', 'info:price', '38000'
put 'products', 'product#pastry002', 'info:category', 'pastry'
put 'products', 'product#pastry002', 'info:isAvailable', 'true'
put 'products', 'product#pastry002', 'info:preparationTime', '3'
put 'products', 'product#pastry002', 'info:imageUrl', 'https://images.unsplash.com/photo-1509440159596-0249088772ff'
put 'products', 'product#pastry002', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry002', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry002', 'options:sizes', '["Standard"]'
put 'products', 'product#pastry002', 'options:options', '[]'

put 'products', 'product#pastry003', 'info:name', 'Bánh Tiramisu'
put 'products', 'product#pastry003', 'info:description', 'Bánh Tiramisu Ý truyền thống với cà phê'
put 'products', 'product#pastry003', 'info:price', '45000'
put 'products', 'product#pastry003', 'info:category', 'pastry'
put 'products', 'product#pastry003', 'info:isAvailable', 'true'
put 'products', 'product#pastry003', 'info:preparationTime', '3'
put 'products', 'product#pastry003', 'info:imageUrl', 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9'
put 'products', 'product#pastry003', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry003', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry003', 'options:sizes', '["Standard"]'
put 'products', 'product#pastry003', 'options:options', '[]'

put 'products', 'product#pastry004', 'info:name', 'Bánh Cheesecake'
put 'products', 'product#pastry004', 'info:description', 'Cheesecake phô mai mềm mịn'
put 'products', 'product#pastry004', 'info:price', '42000'
put 'products', 'product#pastry004', 'info:category', 'pastry'
put 'products', 'product#pastry004', 'info:isAvailable', 'true'
put 'products', 'product#pastry004', 'info:preparationTime', '3'
put 'products', 'product#pastry004', 'info:imageUrl', 'https://images.unsplash.com/photo-1533134486753-c833f0ed4866'
put 'products', 'product#pastry004', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry004', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry004', 'options:sizes', '["Standard"]'
put 'products', 'product#pastry004', 'options:options', '[]'

put 'products', 'product#pastry005', 'info:name', 'Muffin Chocolate Chip'
put 'products', 'product#pastry005', 'info:description', 'Bánh muffin với chocolate chip thơm ngon'
put 'products', 'product#pastry005', 'info:price', '32000'
put 'products', 'product#pastry005', 'info:category', 'pastry'
put 'products', 'product#pastry005', 'info:isAvailable', 'true'
put 'products', 'product#pastry005', 'info:preparationTime', '3'
put 'products', 'product#pastry005', 'info:imageUrl', 'https://images.unsplash.com/photo-1607958996333-41aef7caefaa'
put 'products', 'product#pastry005', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry005', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry005', 'options:sizes', '["Standard"]'
put 'products', 'product#pastry005', 'options:options', '[]'

put 'products', 'product#pastry006', 'info:name', 'Muffin Blueberry'
put 'products', 'product#pastry006', 'info:description', 'Bánh muffin với blueberry tươi'
put 'products', 'product#pastry006', 'info:price', '32000'
put 'products', 'product#pastry006', 'info:category', 'pastry'
put 'products', 'product#pastry006', 'info:isAvailable', 'true'
put 'products', 'product#pastry006', 'info:preparationTime', '3'
put 'products', 'product#pastry006', 'info:imageUrl', 'https://images.unsplash.com/photo-1607958996333-41aef7caefaa'
put 'products', 'product#pastry006', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry006', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry006', 'options:sizes', '["Standard"]'
put 'products', 'product#pastry006', 'options:options', '[]'

# ==================== CÀ PHÊ ĐÓNG GÓI (PACKAGED COFFEE) ====================
put 'products', 'product#pkg001', 'info:name', 'Cà Phê Rang Xay Truyền Thống (500g)'
put 'products', 'product#pkg001', 'info:description', 'Cà phê rang xay Robusta & Arabica pha phin truyền thống'
put 'products', 'product#pkg001', 'info:price', '120000'
put 'products', 'product#pkg001', 'info:category', 'packaged'
put 'products', 'product#pkg001', 'info:isAvailable', 'true'
put 'products', 'product#pkg001', 'info:preparationTime', '2'
put 'products', 'product#pkg001', 'info:imageUrl', 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e'
put 'products', 'product#pkg001', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pkg001', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pkg001', 'options:sizes', '["500g"]'
put 'products', 'product#pkg001', 'options:options', '[{"name":"Dạng","choices":["Bột","Hạt"]}]'

put 'products', 'product#pkg002', 'info:name', 'Cà Phê Rang Xay Moka (500g)'
put 'products', 'product#pkg002', 'info:description', 'Cà phê Arabica Moka thượng hạng'
put 'products', 'product#pkg002', 'info:price', '150000'
put 'products', 'product#pkg002', 'info:category', 'packaged'
put 'products', 'product#pkg002', 'info:isAvailable', 'true'
put 'products', 'product#pkg002', 'info:preparationTime', '2'
put 'products', 'product#pkg002', 'info:imageUrl', 'https://images.unsplash.com/photo-1447933601403-0c6688de566e'
put 'products', 'product#pkg002', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pkg002', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pkg002', 'options:sizes', '["500g"]'
put 'products', 'product#pkg002', 'options:options', '[{"name":"Dạng","choices":["Bột","Hạt"]}]'

put 'products', 'product#pkg003', 'info:name', 'Cà Phê Rang Xay Culi (500g)'
put 'products', 'product#pkg003', 'info:description', 'Cà phê Robusta Culi hạt to đặc biệt'
put 'products', 'product#pkg003', 'info:price', '140000'
put 'products', 'product#pkg003', 'info:category', 'packaged'
put 'products', 'product#pkg003', 'info:isAvailable', 'true'
put 'products', 'product#pkg003', 'info:preparationTime', '2'
put 'products', 'product#pkg003', 'info:imageUrl', 'https://images.unsplash.com/photo-1447933601403-0c6688de566e'
put 'products', 'product#pkg003', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pkg003', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pkg003', 'options:sizes', '["500g"]'
put 'products', 'product#pkg003', 'options:options', '[{"name":"Dạng","choices":["Bột","Hạt"]}]'

put 'products', 'product#pkg004', 'info:name', 'Cà Phê Hòa Tan 3 Trong 1 (Hộp 18 gói)'
put 'products', 'product#pkg004', 'info:description', 'Cà phê hòa tan tiện lợi, đủ vị cà phê - sữa - đường'
put 'products', 'product#pkg004', 'info:price', '65000'
put 'products', 'product#pkg004', 'info:category', 'packaged'
put 'products', 'product#pkg004', 'info:isAvailable', 'true'
put 'products', 'product#pkg004', 'info:preparationTime', '2'
put 'products', 'product#pkg004', 'info:imageUrl', 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd'
put 'products', 'product#pkg004', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pkg004', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pkg004', 'options:sizes', '["18 gói"]'
put 'products', 'product#pkg004', 'options:options', '[]'

put 'products', 'product#pkg005', 'info:name', 'Cà Phê Sữa Lon (235ml)'
put 'products', 'product#pkg005', 'info:description', 'Cà phê sữa đóng lon tiện lợi, uống ngay'
put 'products', 'product#pkg005', 'info:price', '18000'
put 'products', 'product#pkg005', 'info:category', 'packaged'
put 'products', 'product#pkg005', 'info:isAvailable', 'true'
put 'products', 'product#pkg005', 'info:preparationTime', '1'
put 'products', 'product#pkg005', 'info:imageUrl', 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7'
put 'products', 'product#pkg005', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pkg005', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pkg005', 'options:sizes', '["235ml"]'
put 'products', 'product#pkg005', 'options:options', '[]'

# ==================== MERCHANDISE (PHỤ KIỆN) ====================
put 'products', 'product#merch001', 'info:name', 'Bình Giữ Nhiệt Highlands 500ml'
put 'products', 'product#merch001', 'info:description', 'Bình giữ nhiệt inox cao cấp, giữ nóng lạnh 12h'
put 'products', 'product#merch001', 'info:price', '250000'
put 'products', 'product#merch001', 'info:category', 'merchandise'
put 'products', 'product#merch001', 'info:isAvailable', 'true'
put 'products', 'product#merch001', 'info:preparationTime', '1'
put 'products', 'product#merch001', 'info:imageUrl', 'https://images.unsplash.com/photo-1534349762230-e0cadf78f5da'
put 'products', 'product#merch001', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch001', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch001', 'options:sizes', '["500ml"]'
put 'products', 'product#merch001', 'options:options', '[{"name":"Màu sắc","choices":["Đen","Trắng","Xanh","Đỏ"]}]'

put 'products', 'product#merch002', 'info:name', 'Ly Sứ Highlands 350ml'
put 'products', 'product#merch002', 'info:description', 'Ly sứ cao cấp với logo Highlands Coffee'
put 'products', 'product#merch002', 'info:price', '120000'
put 'products', 'product#merch002', 'info:category', 'merchandise'
put 'products', 'product#merch002', 'info:isAvailable', 'true'
put 'products', 'product#merch002', 'info:preparationTime', '1'
put 'products', 'product#merch002', 'info:imageUrl', 'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d'
put 'products', 'product#merch002', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch002', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch002', 'options:sizes', '["350ml"]'
put 'products', 'product#merch002', 'options:options', '[{"name":"Màu sắc","choices":["Trắng","Nâu","Xanh"]}]'

put 'products', 'product#merch003', 'info:name', 'Phin Pha Cà Phê Inox'
put 'products', 'product#merch003', 'info:description', 'Phin pha cà phê inox 304 cao cấp, size 4-6'
put 'products', 'product#merch003', 'info:price', '85000'
put 'products', 'product#merch003', 'info:category', 'merchandise'
put 'products', 'product#merch003', 'info:isAvailable', 'true'
put 'products', 'product#merch003', 'info:preparationTime', '1'
put 'products', 'product#merch003', 'info:imageUrl', 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085'
put 'products', 'product#merch003', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch003', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch003', 'options:sizes', '["Size 4-6"]'
put 'products', 'product#merch003', 'options:options', '[]'

put 'products', 'product#merch004', 'info:name', 'Túi Tote Bag Highlands'
put 'products', 'product#merch004', 'info:description', 'Túi vải canvas thân thiện môi trường'
put 'products', 'product#merch004', 'info:price', '65000'
put 'products', 'product#merch004', 'info:category', 'merchandise'
put 'products', 'product#merch004', 'info:isAvailable', 'true'
put 'products', 'product#merch004', 'info:preparationTime', '1'
put 'products', 'product#merch004', 'info:imageUrl', 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b'
put 'products', 'product#merch004', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch004', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch004', 'options:sizes', '["Standard"]'
put 'products', 'product#merch004', 'options:options', '[{"name":"Màu sắc","choices":["Nâu","Đen","Trắng"]}]'

put 'products', 'product#merch005', 'info:name', 'Áo Thun Highlands Limited Edition'
put 'products', 'product#merch005', 'info:description', 'Áo thun cotton cao cấp phiên bản giới hạn'
put 'products', 'product#merch005', 'info:price', '180000'
put 'products', 'product#merch005', 'info:category', 'merchandise'
put 'products', 'product#merch005', 'info:isAvailable', 'true'
put 'products', 'product#merch005', 'info:preparationTime', '1'
put 'products', 'product#merch005', 'info:imageUrl', 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab'
put 'products', 'product#merch005', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch005', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch005', 'options:sizes', '["S","M","L","XL"]'
put 'products', 'product#merch005', 'options:options', '[{"name":"Màu sắc","choices":["Đen","Trắng","Nâu"]}]'

EOF

echo "Đang thêm đồ ăn và merchandise vào HBase..."
hbase shell /tmp/hbase_food_merchandise.txt

rm /tmp/hbase_food_merchandise.txt

echo ""
echo "========================================="
echo "✅ Hoàn tất!"
echo "========================================="
echo ""
echo "Đã thêm:"
echo "  ✓ Bánh mì: 3 sản phẩm"
echo "  ✓ Bánh ngọt: 6 sản phẩm"
echo "  ✓ Cà phê đóng gói: 5 sản phẩm"
echo "  ✓ Merchandise: 5 sản phẩm"
echo ""
echo "Tổng cộng: 19 sản phẩm đồ ăn và hàng hóa"
echo ""
echo "==========================================
 TỔNG KẾT TẤT CẢ SẢN PHẨM
==========================================
Thức uống (từ seed_products_extended.sh):
  • Cà phê truyền thống: 3
  • Espresso: 5
  • PhinDi đặc biệt: 6
  • Freeze: 5
  • Trà: 9
  Tổng thức uống: 28

Đồ ăn & Hàng hóa (từ file này):
  • Bánh mì: 3
  • Bánh ngọt: 6
  • Cà phê đóng gói: 5
  • Merchandise: 5
  Tổng đồ ăn & hàng hóa: 19

TỔNG CỘNG: 47 SẢN PHẨM
==========================================="
echo ""









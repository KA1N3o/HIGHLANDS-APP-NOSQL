# Highlands Coffee - PowerShell Script to Seed Extended Products
# This script adds the extended product list to HBase

Write-Host "=========================================" -ForegroundColor Green
Write-Host "Seeding Extended Products to HBase" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

# Create HBase commands for extended products
$hbaseCommands = @"
# ==================== CÀ PHÊ TRUYỀN THỐNG ====================
put 'products', 'product#cf001', 'info:name', 'Phin Sữa Đá'
put 'products', 'product#cf001', 'info:description', 'Cà phê phin truyền thống Việt Nam pha với sữa đặc thơm ngon'
put 'products', 'product#cf001', 'info:price', '39000'
put 'products', 'product#cf001', 'info:category', 'coffee'
put 'products', 'product#cf001', 'info:isAvailable', 'true'
put 'products', 'product#cf001', 'info:preparationTime', '8'
put 'products', 'product#cf001', 'info:imageUrl', 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e'
put 'products', 'product#cf001', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#cf001', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#cf001', 'options:sizes', '["Nhỏ","Vừa","Lớn"]'
put 'products', 'product#cf001', 'options:options', '[{"name":"Đường","choices":["Ít đường","Vừa","Nhiều đường"]},{"name":"Đá","choices":["Ít đá","Vừa","Nhiều đá"]}]'

put 'products', 'product#cf002', 'info:name', 'Phin Đen Đá'
put 'products', 'product#cf002', 'info:description', 'Cà phê đen nguyên chất, đậm đà hương vị truyền thống'
put 'products', 'product#cf002', 'info:price', '35000'
put 'products', 'product#cf002', 'info:category', 'coffee'
put 'products', 'product#cf002', 'info:isAvailable', 'true'
put 'products', 'product#cf002', 'info:preparationTime', '8'
put 'products', 'product#cf002', 'info:imageUrl', 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd'
put 'products', 'product#cf002', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#cf002', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#cf002', 'options:sizes', '["Nhỏ","Vừa","Lớn"]'
put 'products', 'product#cf002', 'options:options', '[{"name":"Đường","choices":["Không đường","Ít đường","Vừa","Nhiều đường"]},{"name":"Đá","choices":["Ít đá","Vừa","Nhiều đá"]}]'

put 'products', 'product#cf003', 'info:name', 'Bạc Xỉu'
put 'products', 'product#cf003', 'info:description', 'Cà phê sữa nóng kiểu Việt Nam với hương vị ngọt ngào'
put 'products', 'product#cf003', 'info:price', '39000'
put 'products', 'product#cf003', 'info:category', 'coffee'
put 'products', 'product#cf003', 'info:isAvailable', 'true'
put 'products', 'product#cf003', 'info:preparationTime', '7'
put 'products', 'product#cf003', 'info:imageUrl', 'https://images.unsplash.com/photo-1511920170033-f8396924c348'
put 'products', 'product#cf003', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#cf003', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#cf003', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#cf003', 'options:options', '[{"name":"Đường","choices":["Ít đường","Vừa","Nhiều đường"]}]'

# ==================== ESPRESSO ====================
put 'products', 'product#esp001', 'info:name', 'Latte'
put 'products', 'product#esp001', 'info:description', 'Espresso pha với sữa tươi nóng, mịn màng'
put 'products', 'product#esp001', 'info:price', '49000'
put 'products', 'product#esp001', 'info:category', 'coffee'
put 'products', 'product#esp001', 'info:isAvailable', 'true'
put 'products', 'product#esp001', 'info:preparationTime', '8'
put 'products', 'product#esp001', 'info:imageUrl', 'https://images.unsplash.com/photo-1561882468-9110e03e0f78'
put 'products', 'product#esp001', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#esp001', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#esp001', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#esp001', 'options:options', '[{"name":"Shot","choices":["Single","Double"]},{"name":"Sữa","choices":["Sữa tươi","Sữa hạnh nhân","Sữa yến mạch"]}]'

put 'products', 'product#esp002', 'info:name', 'Cappuccino'
put 'products', 'product#esp002', 'info:description', 'Espresso với lớp bọt sữa dày và mềm'
put 'products', 'product#esp002', 'info:price', '49000'
put 'products', 'product#esp002', 'info:category', 'coffee'
put 'products', 'product#esp002', 'info:isAvailable', 'true'
put 'products', 'product#esp002', 'info:preparationTime', '8'
put 'products', 'product#esp002', 'info:imageUrl', 'https://images.unsplash.com/photo-1534778101976-62847782c213'
put 'products', 'product#esp002', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#esp002', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#esp002', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#esp002', 'options:options', '[{"name":"Shot","choices":["Single","Double"]}]'

put 'products', 'product#esp003', 'info:name', 'Americano'
put 'products', 'product#esp003', 'info:description', 'Espresso pha loãng với nước nóng'
put 'products', 'product#esp003', 'info:price', '45000'
put 'products', 'product#esp003', 'info:category', 'coffee'
put 'products', 'product#esp003', 'info:isAvailable', 'true'
put 'products', 'product#esp003', 'info:preparationTime', '6'
put 'products', 'product#esp003', 'info:imageUrl', 'https://images.unsplash.com/photo-1579992357154-faf4bde95b3d'
put 'products', 'product#esp003', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#esp003', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#esp003', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#esp003', 'options:options', '[{"name":"Shot","choices":["Single","Double"]},{"name":"Nóng/Đá","choices":["Nóng","Đá"]}]'

put 'products', 'product#esp004', 'info:name', 'Caramel Macchiato'
put 'products', 'product#esp004', 'info:description', 'Espresso kết hợp với sữa tươi và caramel thơm ngon'
put 'products', 'product#esp004', 'info:price', '55000'
put 'products', 'product#esp004', 'info:category', 'coffee'
put 'products', 'product#esp004', 'info:isAvailable', 'true'
put 'products', 'product#esp004', 'info:preparationTime', '10'
put 'products', 'product#esp004', 'info:imageUrl', 'https://images.unsplash.com/photo-1572442388796-11668a67e53d'
put 'products', 'product#esp004', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#esp004', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#esp004', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#esp004', 'options:options', '[{"name":"Topping","choices":["Không","Whipped Cream","Extra Caramel"]}]'

put 'products', 'product#esp005', 'info:name', 'Espresso Mocha'
put 'products', 'product#esp005', 'info:description', 'Espresso với chocolate và sữa tươi'
put 'products', 'product#esp005', 'info:price', '52000'
put 'products', 'product#esp005', 'info:category', 'coffee'
put 'products', 'product#esp005', 'info:isAvailable', 'true'
put 'products', 'product#esp005', 'info:preparationTime', '10'
put 'products', 'product#esp005', 'info:imageUrl', 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7'
put 'products', 'product#esp005', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#esp005', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#esp005', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#esp005', 'options:options', '[{"name":"Topping","choices":["Không","Whipped Cream"]}]'

# ==================== PHINDI (CÀ PHÊ ĐẶC BIỆT) ====================
put 'products', 'product#phn001', 'info:name', 'PhinDi Hạnh Nhân'
put 'products', 'product#phn001', 'info:description', 'Cà phê Phin kết hợp với sữa hạnh nhân thơm béo'
put 'products', 'product#phn001', 'info:price', '49000'
put 'products', 'product#phn001', 'info:category', 'coffee'
put 'products', 'product#phn001', 'info:isAvailable', 'true'
put 'products', 'product#phn001', 'info:preparationTime', '10'
put 'products', 'product#phn001', 'info:imageUrl', 'https://images.unsplash.com/photo-1509042239860-f550ce710b93'
put 'products', 'product#phn001', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#phn001', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#phn001', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#phn001', 'options:options', '[{"name":"Đá","choices":["Ít đá","Vừa","Nhiều đá"]}]'

put 'products', 'product#phn002', 'info:name', 'PhinDi Kem Sữa'
put 'products', 'product#phn002', 'info:description', 'Cà phê Phin với lớp kem sữa béo ngậy'
put 'products', 'product#phn002', 'info:price', '45000'
put 'products', 'product#phn002', 'info:category', 'coffee'
put 'products', 'product#phn002', 'info:isAvailable', 'true'
put 'products', 'product#phn002', 'info:preparationTime', '10'
put 'products', 'product#phn002', 'info:imageUrl', 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735'
put 'products', 'product#phn002', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#phn002', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#phn002', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#phn002', 'options:options', '[{"name":"Topping","choices":["Không","Thêm kem"]}]'

put 'products', 'product#phn003', 'info:name', 'PhinDi Choco'
put 'products', 'product#phn003', 'info:description', 'Cà phê Phin kết hợp với chocolate đậm đà'
put 'products', 'product#phn003', 'info:price', '48000'
put 'products', 'product#phn003', 'info:category', 'coffee'
put 'products', 'product#phn003', 'info:isAvailable', 'true'
put 'products', 'product#phn003', 'info:preparationTime', '10'
put 'products', 'product#phn003', 'info:imageUrl', 'https://images.unsplash.com/photo-1485808191679-5f86510681a2'
put 'products', 'product#phn003', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#phn003', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#phn003', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#phn003', 'options:options', '[{"name":"Topping","choices":["Không","Whipped Cream"]}]'

put 'products', 'product#phn004', 'info:name', 'Bạc Xỉu Culi'
put 'products', 'product#phn004', 'info:description', 'Bạc xỉu đặc biệt từ hạt cà phê Culi'
put 'products', 'product#phn004', 'info:price', '42000'
put 'products', 'product#phn004', 'info:category', 'coffee'
put 'products', 'product#phn004', 'info:isAvailable', 'true'
put 'products', 'product#phn004', 'info:preparationTime', '8'
put 'products', 'product#phn004', 'info:imageUrl', 'https://images.unsplash.com/photo-1511920170033-f8396924c348'
put 'products', 'product#phn004', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#phn004', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#phn004', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#phn004', 'options:options', '[{"name":"Đường","choices":["Ít đường","Vừa","Nhiều đường"]}]'

put 'products', 'product#phn005', 'info:name', 'Phin Culi Sữa Đá'
put 'products', 'product#phn005', 'info:description', 'Cà phê Culi pha phin với sữa đá'
put 'products', 'product#phn005', 'info:price', '42000'
put 'products', 'product#phn005', 'info:category', 'coffee'
put 'products', 'product#phn005', 'info:isAvailable', 'true'
put 'products', 'product#phn005', 'info:preparationTime', '8'
put 'products', 'product#phn005', 'info:imageUrl', 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e'
put 'products', 'product#phn005', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#phn005', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#phn005', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#phn005', 'options:options', '[{"name":"Đường","choices":["Ít đường","Vừa","Nhiều đường"]}]'

put 'products', 'product#cbd001', 'info:name', 'Cold Brew Truyền Thống'
put 'products', 'product#cbd001', 'info:description', 'Cà phê ủ lạnh 24h, vị đắng nhẹ, thơm nồng'
put 'products', 'product#cbd001', 'info:price', '52000'
put 'products', 'product#cbd001', 'info:category', 'coffee'
put 'products', 'product#cbd001', 'info:isAvailable', 'true'
put 'products', 'product#cbd001', 'info:preparationTime', '5'
put 'products', 'product#cbd001', 'info:imageUrl', 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7'
put 'products', 'product#cbd001', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#cbd001', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#cbd001', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#cbd001', 'options:options', '[{"name":"Sữa","choices":["Không sữa","Sữa tươi","Sữa hạnh nhân"]}]'

# ==================== FREEZE (ĐÁ XAY) ====================
put 'products', 'product#frz001', 'info:name', 'Caramel Coffee Freeze'
put 'products', 'product#frz001', 'info:description', 'Cà phê đá xay với caramel béo ngậy'
put 'products', 'product#frz001', 'info:price', '59000'
put 'products', 'product#frz001', 'info:category', 'freeze'
put 'products', 'product#frz001', 'info:isAvailable', 'true'
put 'products', 'product#frz001', 'info:preparationTime', '8'
put 'products', 'product#frz001', 'info:imageUrl', 'https://images.unsplash.com/photo-1506617420156-8e4536971650'
put 'products', 'product#frz001', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#frz001', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#frz001', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#frz001', 'options:options', '[{"name":"Topping","choices":["Không","Whipped Cream","Extra Caramel"]}]'

put 'products', 'product#frz002', 'info:name', 'Classic Phin Freeze'
put 'products', 'product#frz002', 'info:description', 'Cà phê phin đá xay phong cách truyền thống'
put 'products', 'product#frz002', 'info:price', '55000'
put 'products', 'product#frz002', 'info:category', 'freeze'
put 'products', 'product#frz002', 'info:isAvailable', 'true'
put 'products', 'product#frz002', 'info:preparationTime', '8'
put 'products', 'product#frz002', 'info:imageUrl', 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7'
put 'products', 'product#frz002', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#frz002', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#frz002', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#frz002', 'options:options', '[{"name":"Topping","choices":["Không","Whipped Cream"]}]'

put 'products', 'product#frz003', 'info:name', 'Green Tea Freeze'
put 'products', 'product#frz003', 'info:description', 'Trà xanh đá xay mát lạnh không cà phê'
put 'products', 'product#frz003', 'info:price', '52000'
put 'products', 'product#frz003', 'info:category', 'freeze'
put 'products', 'product#frz003', 'info:isAvailable', 'true'
put 'products', 'product#frz003', 'info:preparationTime', '7'
put 'products', 'product#frz003', 'info:imageUrl', 'https://images.unsplash.com/photo-1556679343-c7306c1976bc'
put 'products', 'product#frz003', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#frz003', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#frz003', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#frz003', 'options:options', '[{"name":"Topping","choices":["Không","Whipped Cream","Thạch trà xanh"]}]'

put 'products', 'product#frz004', 'info:name', 'Cookies & Cream Freeze'
put 'products', 'product#frz004', 'info:description', 'Đá xay bánh quy Oreo với kem tươi'
put 'products', 'product#frz004', 'info:price', '58000'
put 'products', 'product#frz004', 'info:category', 'freeze'
put 'products', 'product#frz004', 'info:isAvailable', 'true'
put 'products', 'product#frz004', 'info:preparationTime', '7'
put 'products', 'product#frz004', 'info:imageUrl', 'https://images.unsplash.com/photo-1587314168485-3236d6710814'
put 'products', 'product#frz004', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#frz004', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#frz004', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#frz004', 'options:options', '[{"name":"Topping","choices":["Không","Extra Cookies","Whipped Cream"]}]'

put 'products', 'product#frz005', 'info:name', 'Chocolate Freeze'
put 'products', 'product#frz005', 'info:description', 'Đá xay chocolate đậm đà không cà phê'
put 'products', 'product#frz005', 'info:price', '55000'
put 'products', 'product#frz005', 'info:category', 'freeze'
put 'products', 'product#frz005', 'info:isAvailable', 'true'
put 'products', 'product#frz005', 'info:preparationTime', '7'
put 'products', 'product#frz005', 'info:imageUrl', 'https://images.unsplash.com/photo-1542990253-0d0f5be5f0ed'
put 'products', 'product#frz005', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#frz005', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#frz005', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#frz005', 'options:options', '[{"name":"Topping","choices":["Không","Whipped Cream","Chocolate Chips"]}]'

# ==================== TRÀ (TEA) ====================
put 'products', 'product#tea001', 'info:name', 'Trà Sen Vàng'
put 'products', 'product#tea001', 'info:description', 'Trà Ô Long hảo hạng kết hợp với hương sen tinh tế'
put 'products', 'product#tea001', 'info:price', '45000'
put 'products', 'product#tea001', 'info:category', 'tea'
put 'products', 'product#tea001', 'info:isAvailable', 'true'
put 'products', 'product#tea001', 'info:preparationTime', '10'
put 'products', 'product#tea001', 'info:imageUrl', 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=800'
put 'products', 'product#tea001', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#tea001', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#tea001', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#tea001', 'options:options', '[{"name":"Đường","choices":["Không đường","Ít đường","Vừa","Nhiều đường"]},{"name":"Nóng/Đá","choices":["Nóng","Đá"]}]'

put 'products', 'product#tea002', 'info:name', 'Trà Thạch Đào'
put 'products', 'product#tea002', 'info:description', 'Trà Ô Long với thạch đào thơm ngon'
put 'products', 'product#tea002', 'info:price', '49000'
put 'products', 'product#tea002', 'info:category', 'tea'
put 'products', 'product#tea002', 'info:isAvailable', 'true'
put 'products', 'product#tea002', 'info:preparationTime', '12'
put 'products', 'product#tea002', 'info:imageUrl', 'https://images.unsplash.com/photo-1556679343-c7306c1976bc'
put 'products', 'product#tea002', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#tea002', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#tea002', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#tea002', 'options:options', '[{"name":"Đường","choices":["Ít đường","Vừa","Nhiều đường"]},{"name":"Topping","choices":["Không","Thạch đào","Trân châu"]}]'

put 'products', 'product#tea003', 'info:name', 'Trà Thanh Đào'
put 'products', 'product#tea003', 'info:description', 'Trà xanh kết hợp với đào tươi mát lạnh'
put 'products', 'product#tea003', 'info:price', '48000'
put 'products', 'product#tea003', 'info:category', 'tea'
put 'products', 'product#tea003', 'info:isAvailable', 'true'
put 'products', 'product#tea003', 'info:preparationTime', '10'
put 'products', 'product#tea003', 'info:imageUrl', 'https://images.unsplash.com/photo-1544787219-7f47ccb76574'
put 'products', 'product#tea003', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#tea003', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#tea003', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#tea003', 'options:options', '[{"name":"Đường","choices":["Ít đường","Vừa","Nhiều đường"]}]'

put 'products', 'product#tea004', 'info:name', 'Trà Vải'
put 'products', 'product#tea004', 'info:description', 'Trà đen với vải thiều ngọt thanh'
put 'products', 'product#tea004', 'info:price', '48000'
put 'products', 'product#tea004', 'info:category', 'tea'
put 'products', 'product#tea004', 'info:isAvailable', 'true'
put 'products', 'product#tea004', 'info:preparationTime', '10'
put 'products', 'product#tea004', 'info:imageUrl', 'https://images.unsplash.com/photo-1544787219-7f47ccb76574'
put 'products', 'product#tea004', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#tea004', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#tea004', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#tea004', 'options:options', '[{"name":"Đường","choices":["Ít đường","Vừa","Nhiều đường"]}]'

put 'products', 'product#tea005', 'info:name', 'Trà Quả Mọng'
put 'products', 'product#tea005', 'info:description', 'Trà đen kết hợp với hỗn hợp quả mọng'
put 'products', 'product#tea005', 'info:price', '50000'
put 'products', 'product#tea005', 'info:category', 'tea'
put 'products', 'product#tea005', 'info:isAvailable', 'true'
put 'products', 'product#tea005', 'info:preparationTime', '12'
put 'products', 'product#tea005', 'info:imageUrl', 'https://images.unsplash.com/photo-1556679343-c7306c1976bc'
put 'products', 'product#tea005', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#tea005', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#tea005', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#tea005', 'options:options', '[{"name":"Đường","choices":["Ít đường","Vừa","Nhiều đường"]}]'

put 'products', 'product#tea006', 'info:name', 'Trà Ổi Hồng'
put 'products', 'product#tea006', 'info:description', 'Trà xanh với ổi hồng tươi mát'
put 'products', 'product#tea006', 'info:price', '48000'
put 'products', 'product#tea006', 'info:category', 'tea'
put 'products', 'product#tea006', 'info:isAvailable', 'true'
put 'products', 'product#tea006', 'info:preparationTime', '10'
put 'products', 'product#tea006', 'info:imageUrl', 'https://images.unsplash.com/photo-1544787219-7f47ccb76574'
put 'products', 'product#tea006', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#tea006', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#tea006', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#tea006', 'options:options', '[{"name":"Đường","choices":["Ít đường","Vừa","Nhiều đường"]}]'

put 'products', 'product#tea007', 'info:name', 'Green Tea Latte'
put 'products', 'product#tea007', 'info:description', 'Trà xanh matcha với sữa tươi'
put 'products', 'product#tea007', 'info:price', '52000'
put 'products', 'product#tea007', 'info:category', 'tea'
put 'products', 'product#tea007', 'info:isAvailable', 'true'
put 'products', 'product#tea007', 'info:preparationTime', '8'
put 'products', 'product#tea007', 'info:imageUrl', 'https://images.unsplash.com/photo-1564890369478-c89ca6d9cde9'
put 'products', 'product#tea007', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#tea007', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#tea007', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#tea007', 'options:options', '[{"name":"Nóng/Đá","choices":["Nóng","Đá"]},{"name":"Đường","choices":["Ít đường","Vừa","Nhiều đường"]}]'

put 'products', 'product#tea008', 'info:name', 'Trà Sữa Hongkong'
put 'products', 'product#tea008', 'info:description', 'Trà đen Hongkong truyền thống với sữa đặc'
put 'products', 'product#tea008', 'info:price', '45000'
put 'products', 'product#tea008', 'info:category', 'tea'
put 'products', 'product#tea008', 'info:isAvailable', 'true'
put 'products', 'product#tea008', 'info:preparationTime', '8'
put 'products', 'product#tea008', 'info:imageUrl', 'https://images.unsplash.com/photo-1576092768241-dec231879fc3'
put 'products', 'product#tea008', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#tea008', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#tea008', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#tea008', 'options:options', '[{"name":"Đường","choices":["Ít đường","Vừa","Nhiều đường"]},{"name":"Topping","choices":["Không","Trân châu","Thạch"]}]'

put 'products', 'product#tea009', 'info:name', 'Trà Sữa Đài Loan'
put 'products', 'product#tea009', 'info:description', 'Trà Ô Long Đài Loan với sữa tươi béo ngậy'
put 'products', 'product#tea009', 'info:price', '48000'
put 'products', 'product#tea009', 'info:category', 'tea'
put 'products', 'product#tea009', 'info:isAvailable', 'true'
put 'products', 'product#tea009', 'info:preparationTime', '10'
put 'products', 'product#tea009', 'info:imageUrl', 'https://images.unsplash.com/photo-1576092768241-dec231879fc3'
put 'products', 'product#tea009', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#tea009', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#tea009', 'options:sizes', '["Vừa","Lớn"]'
put 'products', 'product#tea009', 'options:options', '[{"name":"Đường","choices":["Ít đường","Vừa","Nhiều đường"]},{"name":"Topping","choices":["Không","Trân châu","Thạch trái cây"]}]'
"@

# Save commands to file
$tempFile = "hbase_extended_products.txt"
$hbaseCommands | Out-File -FilePath $tempFile -Encoding UTF8

Write-Host "✓ Created HBase commands file: $tempFile" -ForegroundColor Green
Write-Host ""

# Check if HBase is available
try {
    $hbaseVersion = hbase version 2>$null
    if ($hbaseVersion) {
        Write-Host "✓ HBase is available" -ForegroundColor Green
        Write-Host ""
        
        # Run HBase shell with the commands file
        Write-Host "Seeding extended products to HBase..." -ForegroundColor Yellow
        hbase shell $tempFile
        
        Write-Host ""
        Write-Host "✓ Extended products seeded successfully!" -ForegroundColor Green
    } else {
        Write-Host "✗ HBase is not available. Please make sure HBase is installed and in PATH." -ForegroundColor Red
        Write-Host ""
        Write-Host "You can manually run these commands by:" -ForegroundColor Yellow
        Write-Host "1. Starting HBase shell: hbase shell" -ForegroundColor Cyan
        Write-Host "2. Copy-pasting the commands from $tempFile" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ Error checking HBase: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "You can manually run these commands by:" -ForegroundColor Yellow
    Write-Host "1. Starting HBase shell: hbase shell" -ForegroundColor Cyan
    Write-Host "2. Copy-pasting the commands from $tempFile" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Extended products seeding completed!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
# Highlands Coffee - PowerShell HBase Data Seeding Script

Write-Host "Creating HBase seed data file..." -ForegroundColor Green

$hbaseCommands = @"
put 'products', 'product#p001', 'info:name', 'Phin Sua Da'
put 'products', 'product#p001', 'info:description', 'Ca phe phin truyen thong Viet Nam'
put 'products', 'product#p001', 'info:price', '39000'
put 'products', 'product#p001', 'info:category', 'coffee'
put 'products', 'product#p001', 'info:isAvailable', 'true'
put 'products', 'product#p001', 'info:preparationTime', '8'
put 'products', 'product#p001', 'options:sizes', '["Small","Medium","Large"]'
put 'products', 'product#p001', 'options:options', '[{"name":"Duong","choices":["It","Vua","Nhieu"]}]'

put 'products', 'product#p002', 'info:name', 'Bac Xiu'
put 'products', 'product#p002', 'info:description', 'Ca phe sua nong kieu Viet Nam'
put 'products', 'product#p002', 'info:price', '39000'
put 'products', 'product#p002', 'info:category', 'coffee'
put 'products', 'product#p002', 'info:isAvailable', 'true'
put 'products', 'product#p002', 'info:preparationTime', '7'
put 'products', 'product#p002', 'options:sizes', '["Small","Medium","Large"]'
put 'products', 'product#p002', 'options:options', '[{"name":"Duong","choices":["It","Vua","Nhieu"]}]'

put 'products', 'product#p003', 'info:name', 'Caramel Macchiato'
put 'products', 'product#p003', 'info:description', 'Espresso ket hop voi sua tuoi va caramel'
put 'products', 'product#p003', 'info:price', '55000'
put 'products', 'product#p003', 'info:category', 'coffee'
put 'products', 'product#p003', 'info:isAvailable', 'true'
put 'products', 'product#p003', 'info:preparationTime', '10'
put 'products', 'product#p003', 'options:sizes', '["Medium","Large"]'
put 'products', 'product#p003', 'options:options', '[{"name":"Topping","choices":["Khong","Whipped Cream","Extra Caramel"]}]'

put 'products', 'product#p004', 'info:name', 'Cappuccino'
put 'products', 'product#p004', 'info:description', 'Ca phe Y truyen thong voi bot sua min'
put 'products', 'product#p004', 'info:price', '49000'
put 'products', 'product#p004', 'info:category', 'coffee'
put 'products', 'product#p004', 'info:isAvailable', 'true'
put 'products', 'product#p004', 'info:preparationTime', '8'
put 'products', 'product#p004', 'options:sizes', '["Small","Medium","Large"]'
put 'products', 'product#p004', 'options:options', '[{"name":"Shot","choices":["Single","Double"]}]'

put 'products', 'product#p005', 'info:name', 'Tra Dao Cam Sa'
put 'products', 'product#p005', 'info:description', 'Tra den ket hop voi dao, cam va sa'
put 'products', 'product#p005', 'info:price', '49000'
put 'products', 'product#p005', 'info:category', 'tea'
put 'products', 'product#p005', 'info:isAvailable', 'true'
put 'products', 'product#p005', 'info:preparationTime', '12'
put 'products', 'product#p005', 'options:sizes', '["Medium","Large"]'
put 'products', 'product#p005', 'options:options', '[{"name":"Duong","choices":["It","Vua","Nhieu"]}]'

put 'products', 'product#p006', 'info:name', 'Smoothie Xoai'
put 'products', 'product#p006', 'info:description', 'Sinh to xoai tuoi mat lanh'
put 'products', 'product#p006', 'info:price', '59000'
put 'products', 'product#p006', 'info:category', 'smoothie'
put 'products', 'product#p006', 'info:isAvailable', 'true'
put 'products', 'product#p006', 'info:preparationTime', '10'
put 'products', 'product#p006', 'options:sizes', '["Medium","Large"]'
put 'products', 'product#p006', 'options:options', '[{"name":"Topping","choices":["Khong","Thach dua","Tran chau"]}]'

put 'products', 'product#p007', 'info:name', 'Banh Mi Pate'
put 'products', 'product#p007', 'info:description', 'Banh mi Viet Nam voi pate va thit'
put 'products', 'product#p007', 'info:price', '32000'
put 'products', 'product#p007', 'info:category', 'food'
put 'products', 'product#p007', 'info:isAvailable', 'true'
put 'products', 'product#p007', 'info:preparationTime', '5'
put 'products', 'product#p007', 'options:sizes', '["Standard"]'
put 'products', 'product#p007', 'options:options', '[{"name":"Do cay","choices":["Khong cay","It cay","Cay vua"]}]'

put 'products', 'product#p008', 'info:name', 'Banh Croissant'
put 'products', 'product#p008', 'info:description', 'Banh sung bo bo thom gion'
put 'products', 'product#p008', 'info:price', '35000'
put 'products', 'product#p008', 'info:category', 'pastry'
put 'products', 'product#p008', 'info:isAvailable', 'true'
put 'products', 'product#p008', 'info:preparationTime', '3'
put 'products', 'product#p008', 'options:sizes', '["Standard"]'
put 'products', 'product#p008', 'options:options', '[]'

put 'stores', 'store#s001', 'info:name', 'Highlands Coffee - Nguyen Hue'
put 'stores', 'store#s001', 'info:address', '123 Nguyen Hue, Q.1, TP.HCM'
put 'stores', 'store#s001', 'info:latitude', '10.7756'
put 'stores', 'store#s001', 'info:longitude', '106.7019'
put 'stores', 'store#s001', 'info:phone', '0901234567'
put 'stores', 'store#s001', 'info:isOpen', 'true'
put 'stores', 'store#s001', 'hours:openTime', '07:00'
put 'stores', 'store#s001', 'hours:closeTime', '22:00'

put 'stores', 'store#s002', 'info:name', 'Highlands Coffee - Le Loi'
put 'stores', 'store#s002', 'info:address', '456 Le Loi, Q.1, TP.HCM'
put 'stores', 'store#s002', 'info:latitude', '10.7727'
put 'stores', 'store#s002', 'info:longitude', '106.6988'
put 'stores', 'store#s002', 'info:phone', '0901234568'
put 'stores', 'store#s002', 'info:isOpen', 'true'
put 'stores', 'store#s002', 'hours:openTime', '07:00'
put 'stores', 'store#s002', 'hours:closeTime', '23:00'

put 'stores', 'store#s003', 'info:name', 'Highlands Coffee - Vincom Center'
put 'stores', 'store#s003', 'info:address', '72 Le Thanh Ton, Q.1, TP.HCM'
put 'stores', 'store#s003', 'info:latitude', '10.7797'
put 'stores', 'store#s003', 'info:longitude', '106.7011'
put 'stores', 'store#s003', 'info:phone', '0901234569'
put 'stores', 'store#s003', 'info:isOpen', 'true'
put 'stores', 'store#s003', 'hours:openTime', '08:00'
put 'stores', 'store#s003', 'hours:closeTime', '22:00'

put 'stores', 'store#s004', 'info:name', 'Highlands Coffee - Landmark 81'
put 'stores', 'store#s004', 'info:address', '720A Dien Bien Phu, Binh Thanh, TP.HCM'
put 'stores', 'store#s004', 'info:latitude', '10.7943'
put 'stores', 'store#s004', 'info:longitude', '106.7218'
put 'stores', 'store#s004', 'info:phone', '0901234570'
put 'stores', 'store#s004', 'info:isOpen', 'true'
put 'stores', 'store#s004', 'hours:openTime', '08:00'
put 'stores', 'store#s004', 'hours:closeTime', '22:00'

put 'stores', 'store#s005', 'info:name', 'Highlands Coffee - Crescent Mall'
put 'stores', 'store#s005', 'info:address', '101 Ton Dat Tien, Q.7, TP.HCM'
put 'stores', 'store#s005', 'info:latitude', '10.7285'
put 'stores', 'store#s005', 'info:longitude', '106.7198'
put 'stores', 'store#s005', 'info:phone', '0901234571'
put 'stores', 'store#s005', 'info:isOpen', 'true'
put 'stores', 'store#s005', 'hours:openTime', '08:00'
put 'stores', 'store#s005', 'hours:closeTime', '22:00'

put 'users', 'user#admin001', 'profile:email', 'admin@highlands.vn'
put 'users', 'user#admin001', 'profile:name', 'Admin User'
put 'users', 'user#admin001', 'profile:phone', '0900000001'
put 'users', 'user#admin001', 'profile:role', 'admin'
put 'users', 'user#admin001', 'profile:createdAt', '2024-01-01T00:00:00Z'
put 'users', 'user#admin001', 'auth:passwordHash', 'hashed_password_here'
put 'users', 'user#admin001', 'auth:salt', 'salt_here'

put 'users', 'user#test001', 'profile:email', 'test@highlands.vn'
put 'users', 'user#test001', 'profile:name', 'Test User'
put 'users', 'user#test001', 'profile:phone', '0900000000'
put 'users', 'user#test001', 'profile:role', 'customer'
put 'users', 'user#test001', 'profile:createdAt', '2024-01-01T00:00:00Z'
put 'users', 'user#test001', 'auth:passwordHash', 'hashed_password_here'
put 'users', 'user#test001', 'auth:salt', 'salt_here'
"@

$hbaseCommands | Out-File -FilePath "hbase_seed_data.txt" -Encoding UTF8

Write-Host "HBase seed data file created!" -ForegroundColor Green
Write-Host "Run: hbase shell < hbase_seed_data.txt" -ForegroundColor Yellow























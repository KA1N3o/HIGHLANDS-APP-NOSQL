#!/bin/bash

# Highlands Coffee - Sample Data Seeding Script
# This script populates the Bigtable tables with sample data

set -e

echo "========================================="
echo "Seeding Sample Data to Bigtable"
echo "========================================="
echo ""

# Seed Products
echo "Seeding products..."

cbt set products product#p001 info:name="Phin Sữa Đá" info:description="Cà phê phin truyền thống Việt Nam pha với sữa đặc" info:price="39000" info:imageUrl="https://images.unsplash.com/photo-1559056199-641a0ac8b55e" info:category="coffee" info:isAvailable="true" info:preparationTime="8" options:sizes='["Small","Medium","Large"]' options:optionsData='[{"name":"Đường","choices":["Ít đường","Vừa","Nhiều đường"],"extraPrice":0}]'

cbt set products product#p002 info:name="Bạc Xỉu" info:description="Cà phê sữa nóng kiểu Việt Nam với hương vị ngọt ngào" info:price="39000" info:imageUrl="https://images.unsplash.com/photo-1511920170033-f8396924c348" info:category="coffee" info:isAvailable="true" info:preparationTime="7" options:sizes='["Small","Medium","Large"]' options:optionsData='[{"name":"Đường","choices":["Ít đường","Vừa","Nhiều đường"],"extraPrice":0}]'

cbt set products product#p003 info:name="Caramel Macchiato" info:description="Espresso kết hợp với sữa tươi và caramel thơm ngon" info:price="55000" info:imageUrl="https://images.unsplash.com/photo-1572442388796-11668a67e53d" info:category="coffee" info:isAvailable="true" info:preparationTime="10" options:sizes='["Medium","Large"]' options:optionsData='[{"name":"Topping","choices":["Không","Whipped Cream","Extra Caramel"],"extraPrice":10000}]'

cbt set products product#p004 info:name="Cappuccino" info:description="Cà phê Ý truyền thống với bọt sữa mịn màng" info:price="49000" info:imageUrl="https://images.unsplash.com/photo-1534778101976-62847782c213" info:category="coffee" info:isAvailable="true" info:preparationTime="8" options:sizes='["Small","Medium","Large"]' options:optionsData='[{"name":"Shot","choices":["Single","Double"],"extraPrice":15000}]'

cbt set products product#p005 info:name="Trà Đào Cam Sả" info:description="Trà đen kết hợp với đào, cam và sả thơm mát" info:price="49000" info:imageUrl="https://images.unsplash.com/photo-1556679343-c7306c1976bc" info:category="tea" info:isAvailable="true" info:preparationTime="12" options:sizes='["Medium","Large"]' options:optionsData='[{"name":"Đường","choices":["Ít đường","Vừa","Nhiều đường"],"extraPrice":0}]'

cbt set products product#p006 info:name="Smoothie Xoài" info:description="Sinh tố xoài tươi mát lạnh, ngọt tự nhiên" info:price="59000" info:imageUrl="https://images.unsplash.com/photo-1505252585461-04db1eb84625" info:category="smoothie" info:isAvailable="true" info:preparationTime="10" options:sizes='["Medium","Large"]' options:optionsData='[{"name":"Topping","choices":["Không","Thạch dừa","Trân châu"],"extraPrice":10000}]'

cbt set products product#p007 info:name="Bánh Mì Pate" info:description="Bánh mì Việt Nam với pate, thịt nguội và rau thơm" info:price="32000" info:imageUrl="https://images.unsplash.com/photo-1525351484163-7529414344d8" info:category="food" info:isAvailable="true" info:preparationTime="5" options:sizes='["Standard"]' options:optionsData='[{"name":"Độ cay","choices":["Không cay","Ít cay","Cay vừa","Cay nhiều"],"extraPrice":0}]'

cbt set products product#p008 info:name="Bánh Croissant" info:description="Bánh sừng bò bơ thơm giòn tan" info:price="35000" info:imageUrl="https://images.unsplash.com/photo-1555507036-ab1f4038808a" info:category="pastry" info:isAvailable="true" info:preparationTime="3" options:sizes='["Standard"]' options:optionsData='[]'

echo "✓ Products seeded successfully"

# Seed Stores
echo ""
echo "Seeding stores..."

cbt set stores store#s001 info:name="Highlands Coffee - Nguyễn Huệ" info:address="123 Nguyễn Huệ, Q.1, TP.HCM" info:latitude="10.7756" info:longitude="106.7019" info:phone="0901234567" info:imageUrl="https://images.unsplash.com/photo-1554118811-1e0d58224f24" info:isOpen="true" hours:openTime="07:00" hours:closeTime="22:00"

cbt set stores store#s002 info:name="Highlands Coffee - Lê Lợi" info:address="456 Lê Lợi, Q.1, TP.HCM" info:latitude="10.7727" info:longitude="106.6988" info:phone="0901234568" info:imageUrl="https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb" info:isOpen="true" hours:openTime="07:00" hours:closeTime="23:00"

cbt set stores store#s003 info:name="Highlands Coffee - Vincom Center" info:address="72 Lê Thánh Tôn, Q.1, TP.HCM" info:latitude="10.7797" info:longitude="106.7011" info:phone="0901234569" info:imageUrl="https://images.unsplash.com/photo-1559496417-e7f25c30ff3e" info:isOpen="true" hours:openTime="08:00" hours:closeTime="22:00"

cbt set stores store#s004 info:name="Highlands Coffee - Landmark 81" info:address="720A Điện Biên Phủ, Bình Thạnh, TP.HCM" info:latitude="10.7943" info:longitude="106.7218" info:phone="0901234570" info:imageUrl="https://images.unsplash.com/photo-1511920170033-f8396924c348" info:isOpen="true" hours:openTime="08:00" hours:closeTime="22:00"

cbt set stores store#s005 info:name="Highlands Coffee - Crescent Mall" info:address="101 Tôn Dật Tiên, Q.7, TP.HCM" info:latitude="10.7285" info:longitude="106.7198" info:phone="0901234571" info:imageUrl="https://images.unsplash.com/photo-1442512595331-e89e73853f31" info:isOpen="true" hours:openTime="08:00" hours:closeTime="22:00"

echo "✓ Stores seeded successfully"

# Seed Test User
echo ""
echo "Seeding test user..."

cbt set users user#test001 profile:email="test@highlands.vn" profile:name="Test User" profile:phone="0900000000" profile:role="customer" profile:createdAt="2024-01-01T00:00:00Z" auth:passwordHash="hashed_password_here" auth:salt="salt_here"

cbt set users user#admin001 profile:email="admin@highlands.vn" profile:name="Admin User" profile:phone="0900000001" profile:role="admin" profile:createdAt="2024-01-01T00:00:00Z" auth:passwordHash="hashed_password_here" auth:salt="salt_here"

echo "✓ Test users seeded successfully"

echo ""
echo "========================================="
echo "Sample data seeding completed!"
echo "========================================="
echo ""
echo "Test accounts created:"
echo "  Customer: test@highlands.vn"
echo "  Admin: admin@highlands.vn"
echo ""
echo "Data seeded:"
echo "  - 8 products"
echo "  - 5 stores"
echo "  - 2 test users"
echo ""
echo "You can now:"
echo "1. Test the application with sample data"
echo "2. View data with: cbt read <table_name>"
echo "3. Connect your Flutter app to Bigtable"
echo ""


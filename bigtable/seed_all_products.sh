#!/bin/bash

# Highlands Coffee - Seed ALL Products
# Script master để thêm TẤT CẢ sản phẩm vào HBase

set -e

echo "==========================================="
echo "   HIGHLANDS COFFEE - SEED ALL PRODUCTS"
echo "==========================================="
echo ""
echo "Script này sẽ thêm 47+ sản phẩm vào database"
echo ""
echo "Bao gồm:"
echo "  ✓ Cà phê truyền thống (3)"
echo "  ✓ Espresso (5)"
echo "  ✓ PhinDi đặc biệt (6)"
echo "  ✓ Freeze - Đá xay (5)"
echo "  ✓ Trà các loại (9)"
echo "  ✓ Bánh mì (3)"
echo "  ✓ Bánh ngọt (6)"
echo "  ✓ Cà phê đóng gói (5)"
echo "  ✓ Merchandise (5)"
echo ""
read -p "Bạn có muốn tiếp tục? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Đã hủy."
    exit 1
fi

echo ""
echo "Đang bắt đầu..."
echo ""

# Kiểm tra HBase shell
if ! command -v hbase &> /dev/null; then
    echo "❌ Error: HBase không được cài đặt hoặc không trong PATH"
    exit 1
fi

echo "✓ HBase command được tìm thấy"
echo ""

# Chạy script 1: Thức uống
echo "============================================"
echo "BƯỚC 1: Thêm thức uống (28 sản phẩm)"
echo "============================================"
chmod +x seed_products_extended.sh
./seed_products_extended.sh

echo ""
echo "============================================"
echo "BƯỚC 2: Thêm đồ ăn & merchandise (19 sản phẩm)"
echo "============================================"
chmod +x seed_food_merchandise.sh
./seed_food_merchandise.sh

echo ""
echo "==========================================="
echo "✅ ✅ ✅  HOÀN TẤT TẤT CẢ!  ✅ ✅ ✅"
echo "==========================================="
echo ""
echo "Đã thêm thành công 47+ sản phẩm vào database!"
echo ""
echo "Danh mục đầy đủ:"
echo "  ☕ CÀ PHÊ:"
echo "    • Truyền thống: Phin Sữa Đá, Phin Đen, Bạc Xỉu"
echo "    • Espresso: Latte, Cappuccino, Americano, Caramel Macchiato, Mocha"
echo "    • PhinDi: Hạnh Nhân, Kem Sữa, Choco, Bạc Xỉu Culi, Phin Culi, Cold Brew"
echo ""
echo "  🧊 FREEZE (Đá xay):"
echo "    • Có cà phê: Caramel Coffee, Classic Phin"
echo "    • Không cà phê: Green Tea, Cookies & Cream, Chocolate"
echo ""
echo "  🍵 TRÀ:"
echo "    • Trà truyền thống: Sen Vàng, Thạch Đào, Thanh Đào, Vải, Quả Mọng, Ổi Hồng"
echo "    • Trà sữa: Green Tea Latte, Trà Sữa Hongkong, Trà Sữa Đài Loan"
echo ""
echo "  🥖 THỨC ĂN:"
echo "    • Bánh mì: Bò Phô Mai, Gà Phô Mai, Pate"
echo "    • Bánh ngọt: Croissant, Tiramisu, Cheesecake, Muffin"
echo ""
echo "  📦 ĐÓNG GÓI:"
echo "    • Cà phê: Rang Xay, Hòa Tan, Đóng Lon"
echo ""
echo "  🎁 MERCHANDISE:"
echo "    • Bình giữ nhiệt, Ly sứ, Phin inox, Túi Tote, Áo thun"
echo ""
echo "Kiểm tra database:"
echo "  hbase shell"
echo "  > scan 'products', {LIMIT => 10}"
echo "  > count 'products'"
echo ""
echo "Hoặc test API:"
echo "  curl http://localhost:8080/api/products -H \"Authorization: Bearer TOKEN\""
echo ""
echo "Chúc bạn thành công! 🚀"
echo ""







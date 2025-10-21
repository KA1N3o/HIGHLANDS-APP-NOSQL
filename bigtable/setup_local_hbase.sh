#!/bin/bash

# Highlands Coffee - Local HBase Setup Script
# Sử dụng script này nếu bạn đang chạy HBase local (không phải Google Cloud Bigtable)

set -e

echo "========================================="
echo "Highlands Coffee - Local HBase Setup"
echo "========================================="
echo ""

# Kiểm tra HBase shell có sẵn không
if ! command -v hbase &> /dev/null; then
    echo "❌ Error: HBase không được cài đặt hoặc không trong PATH"
    echo "Vui lòng cài đặt HBase và đảm bảo 'hbase' command có thể chạy được"
    exit 1
fi

echo "✓ HBase command được tìm thấy"
echo ""

# Tạo file HBase commands
cat > /tmp/hbase_create_tables.txt << 'EOF'
# Create Users table
create 'users', {NAME => 'profile', VERSIONS => 1}, {NAME => 'auth', VERSIONS => 1}

# Create Products table
create 'products', {NAME => 'info', VERSIONS => 1}, {NAME => 'options', VERSIONS => 1}

# Create Stores table
create 'stores', {NAME => 'info', VERSIONS => 1}, {NAME => 'hours', VERSIONS => 1}

# Create Orders table
create 'orders', {NAME => 'info', VERSIONS => 1}, {NAME => 'payment', VERSIONS => 1}, {NAME => 'items', VERSIONS => 1}

# Create Orders by user index table
create 'orders_by_user', {NAME => 'ref', VERSIONS => 1}

# Create Sessions table (với TTL 30 ngày = 2592000 giây)
create 'sessions', {NAME => 'data', TTL => 2592000, VERSIONS => 1}

# Create Carts table
create 'carts', {NAME => 'items', VERSIONS => 1}, {NAME => 'meta', VERSIONS => 1}

# Create Deliveries table
create 'deliveries', {NAME => 'info', VERSIONS => 1}

# Create Promotions table
create 'promotions', {NAME => 'info', VERSIONS => 1}

# Create Payments table
create 'payments', {NAME => 'info', VERSIONS => 1}

# List all tables
list
EOF

echo "Đang tạo tables trong HBase..."
echo ""

# Chạy HBase shell với file commands
hbase shell /tmp/hbase_create_tables.txt

# Xóa file tạm
rm /tmp/hbase_create_tables.txt

echo ""
echo "========================================="
echo "✅ Setup hoàn tất!"
echo "========================================="
echo ""
echo "Các tables đã được tạo:"
echo "  ✓ users           - Quản lý người dùng"
echo "  ✓ products        - Danh mục sản phẩm"
echo "  ✓ stores          - Thông tin cửa hàng"
echo "  ✓ orders          - Đơn hàng"
echo "  ✓ orders_by_user  - Index cho user orders"
echo "  ✓ sessions        - JWT sessions"
echo "  ✓ carts           - Giỏ hàng"
echo "  ✓ deliveries      - Thông tin giao hàng"
echo "  ✓ promotions      - Mã khuyến mãi"
echo "  ✓ payments        - Thông tin thanh toán"
echo ""
echo "Bước tiếp theo:"
echo "1. Chạy './seed_local_hbase.sh' để thêm dữ liệu mẫu"
echo "2. Cập nhật file .env trong backend với thông tin HBase của bạn"
echo "3. Chạy backend server: cd backend && npm run dev"
echo ""
echo "Kiểm tra tables:"
echo "  hbase shell"
echo "  > list"
echo "  > describe 'users'"
echo ""









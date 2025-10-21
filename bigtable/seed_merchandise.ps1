# Highlands Coffee - Seed Merchandise Products to HBase
# Script to add merchandise products (bottles, mugs, bags, t-shirts) to database

Write-Host "=========================================" -ForegroundColor Green
Write-Host "Seeding Merchandise Products to HBase" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

# Create HBase commands for merchandise products
$hbaseCommands = @"
# ==================== MERCHANDISE - SẢN PHẨM HIGHLANDS ====================

put 'products', 'product#merch001', 'info:name', 'Bình Giữ Nhiệt Highlands 500ml'
put 'products', 'product#merch001', 'info:description', 'Bình giữ nhiệt inox cao cấp, giữ nhiệt lạnh đến 12 giờ, giữ nóng 6 giờ'
put 'products', 'product#merch001', 'info:price', '250000'
put 'products', 'product#merch001', 'info:category', 'merchandise'
put 'products', 'product#merch001', 'info:isAvailable', 'true'
put 'products', 'product#merch001', 'info:preparationTime', '0'
put 'products', 'product#merch001', 'info:imageUrl', 'https://images.unsplash.com/photo-1602143407151-7111542de6e8'
put 'products', 'product#merch001', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch001', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch001', 'options:sizes', '["500ml"]'
put 'products', 'product#merch001', 'options:options', '[]'

put 'products', 'product#merch002', 'info:name', 'Ly Sứ Highlands 350ml'
put 'products', 'product#merch002', 'info:description', 'Ly sứ cao cấp với logo Highlands, thiết kế sang trọng và hiện đại'
put 'products', 'product#merch002', 'info:price', '120000'
put 'products', 'product#merch002', 'info:category', 'merchandise'
put 'products', 'product#merch002', 'info:isAvailable', 'true'
put 'products', 'product#merch002', 'info:preparationTime', '0'
put 'products', 'product#merch002', 'info:imageUrl', 'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d'
put 'products', 'product#merch002', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch002', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch002', 'options:sizes', '["350ml"]'
put 'products', 'product#merch002', 'options:options', '[]'

put 'products', 'product#merch003', 'info:name', 'Phín Pha Cà Phê Inox'
put 'products', 'product#merch003', 'info:description', 'Phín pha cà phê truyền thống bằng inox 304, chất lượng cao, size 4-6 người'
put 'products', 'product#merch003', 'info:price', '85000'
put 'products', 'product#merch003', 'info:category', 'merchandise'
put 'products', 'product#merch003', 'info:isAvailable', 'true'
put 'products', 'product#merch003', 'info:preparationTime', '0'
put 'products', 'product#merch003', 'info:imageUrl', 'https://images.unsplash.com/photo-1610889556528-9a770e32642f'
put 'products', 'product#merch003', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch003', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch003', 'options:sizes', '["Standard"]'
put 'products', 'product#merch003', 'options:options', '[]'

put 'products', 'product#merch004', 'info:name', 'Túi Tote Bag Highlands'
put 'products', 'product#merch004', 'info:description', 'Túi vải canvas bền đẹp với thiết kế Highlands độc đáo, thân thiện môi trường'
put 'products', 'product#merch004', 'info:price', '95000'
put 'products', 'product#merch004', 'info:category', 'merchandise'
put 'products', 'product#merch004', 'info:isAvailable', 'true'
put 'products', 'product#merch004', 'info:preparationTime', '0'
put 'products', 'product#merch004', 'info:imageUrl', 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7'
put 'products', 'product#merch004', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch004', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch004', 'options:sizes', '["One Size"]'
put 'products', 'product#merch004', 'options:options', '[{"name":"Màu sắc","choices":["Trắng","Be","Xanh"]}]'

put 'products', 'product#merch005', 'info:name', 'Áo Thun Highlands Limited Edition'
put 'products', 'product#merch005', 'info:description', 'Áo thun cotton cao cấp với thiết kế độc quyền, phiên bản giới hạn'
put 'products', 'product#merch005', 'info:price', '195000'
put 'products', 'product#merch005', 'info:category', 'merchandise'
put 'products', 'product#merch005', 'info:isAvailable', 'true'
put 'products', 'product#merch005', 'info:preparationTime', '0'
put 'products', 'product#merch005', 'info:imageUrl', 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab'
put 'products', 'product#merch005', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch005', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#merch005', 'options:sizes', '["S","M","L","XL"]'
put 'products', 'product#merch005', 'options:options', '[{"name":"Màu sắc","choices":["Trắng","Đen","Xanh Navy"]}]'

"@

# Save commands to file
$tempFile = "hbase_merchandise.txt"
$hbaseCommands | Out-File -FilePath $tempFile -Encoding UTF8

Write-Host "✓ Created HBase commands file: $tempFile" -ForegroundColor Green
Write-Host "✓ Total merchandise products: 5" -ForegroundColor Cyan
Write-Host ""

# Check if HBase is available
try {
    $hbaseVersion = hbase version 2>$null
    if ($hbaseVersion) {
        Write-Host "✓ HBase is available" -ForegroundColor Green
        Write-Host ""
        
        # Run HBase shell with the commands file
        Write-Host "Seeding merchandise products to HBase..." -ForegroundColor Yellow
        hbase shell $tempFile
        
        Write-Host ""
        Write-Host "✓ Merchandise products seeded successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Products added:" -ForegroundColor Cyan
        Write-Host "  • Bình Giữ Nhiệt Highlands 500ml - 250,000đ" -ForegroundColor White
        Write-Host "  • Ly Sứ Highlands 350ml - 120,000đ" -ForegroundColor White
        Write-Host "  • Phín Pha Cà Phê Inox - 85,000đ" -ForegroundColor White
        Write-Host "  • Túi Tote Bag Highlands - 95,000đ" -ForegroundColor White
        Write-Host "  • Áo Thun Highlands Limited Edition - 195,000đ" -ForegroundColor White
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
Write-Host "Merchandise seeding completed!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""


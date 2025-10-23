# Highlands Coffee - Script Thêm Bánh Ngọt Mới
# Script này thêm các loại bánh ngọt mới vào HBase

Write-Host "=========================================" -ForegroundColor Green
Write-Host "Thêm Bánh Ngọt Mới Vào HBase" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

# Create HBase commands for new pastries
$hbaseCommands = @"
# ==================== BÁNH NGỌT MỚI ====================

put 'products', 'product#pastry007', 'info:name', 'Bánh Su Kem'
put 'products', 'product#pastry007', 'info:description', 'Bánh su kem nhỏ xinh với nhân kem tươi béo ngậy, vỏ bánh giòn tan'
put 'products', 'product#pastry007', 'info:price', '38000'
put 'products', 'product#pastry007', 'info:category', 'pastry'
put 'products', 'product#pastry007', 'info:isAvailable', 'true'
put 'products', 'product#pastry007', 'info:preparationTime', '5'
put 'products', 'product#pastry007', 'info:rating', '4.5'
put 'products', 'product#pastry007', 'info:reviewCount', '0'
put 'products', 'product#pastry007', 'info:imageUrl', 'https://images.unsplash.com/photo-1612201142855-e7f82f9ab9e8'
put 'products', 'product#pastry007', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry007', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry007', 'options:sizes', '["Standard"]'
put 'products', 'product#pastry007', 'options:options', '[{"name":"Nhân","choices":["Kem vani","Kem chocolate","Kem trà xanh"]}]'

put 'products', 'product#pastry008', 'info:name', 'Bánh Sữa Chua Phô Mai'
put 'products', 'product#pastry008', 'info:description', 'Bánh sữa chua phô mai mềm mịn, hương vị thanh mát, chua nhẹ'
put 'products', 'product#pastry008', 'info:price', '45000'
put 'products', 'product#pastry008', 'info:category', 'pastry'
put 'products', 'product#pastry008', 'info:isAvailable', 'true'
put 'products', 'product#pastry008', 'info:preparationTime', '5'
put 'products', 'product#pastry008', 'info:rating', '4.5'
put 'products', 'product#pastry008', 'info:reviewCount', '0'
put 'products', 'product#pastry008', 'info:imageUrl', 'https://images.unsplash.com/photo-1621303837174-89787a7d4729'
put 'products', 'product#pastry008', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry008', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry008', 'options:sizes', '["Standard"]'
put 'products', 'product#pastry008', 'options:options', '[{"name":"Topping","choices":["Không","Quả mọng","Dâu tây"]}]'

put 'products', 'product#pastry009', 'info:name', 'Bánh Phô Mai Trà Xanh'
put 'products', 'product#pastry009', 'info:description', 'Cheesecake trà xanh matcha Nhật Bản, vị béo ngậy kết hợp hương trà đặc trưng'
put 'products', 'product#pastry009', 'info:price', '48000'
put 'products', 'product#pastry009', 'info:category', 'pastry'
put 'products', 'product#pastry009', 'info:isAvailable', 'true'
put 'products', 'product#pastry009', 'info:preparationTime', '5'
put 'products', 'product#pastry009', 'info:rating', '4.5'
put 'products', 'product#pastry009', 'info:reviewCount', '0'
put 'products', 'product#pastry009', 'info:imageUrl', 'https://images.unsplash.com/photo-1565958011703-44f9829ba187'
put 'products', 'product#pastry009', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry009', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry009', 'options:sizes', '["Standard"]'
put 'products', 'product#pastry009', 'options:options', '[{"name":"Topping","choices":["Không","Whipped Cream","Red Bean"]}]'

put 'products', 'product#pastry010', 'info:name', 'Bánh Phô Mai Chanh Dây'
put 'products', 'product#pastry010', 'info:description', 'Cheesecake chanh dây nhiệt đới, vị chua ngọt hài hòa, thanh mát'
put 'products', 'product#pastry010', 'info:price', '48000'
put 'products', 'product#pastry010', 'info:category', 'pastry'
put 'products', 'product#pastry010', 'info:isAvailable', 'true'
put 'products', 'product#pastry010', 'info:preparationTime', '5'
put 'products', 'product#pastry010', 'info:rating', '4.5'
put 'products', 'product#pastry010', 'info:reviewCount', '0'
put 'products', 'product#pastry010', 'info:imageUrl', 'https://images.unsplash.com/photo-1533134242820-31a6d23e64b4'
put 'products', 'product#pastry010', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry010', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry010', 'options:sizes', '["Standard"]'
put 'products', 'product#pastry010', 'options:options', '[{"name":"Topping","choices":["Không","Whipped Cream","Chanh dây tươi"]}]'

put 'products', 'product#pastry011', 'info:name', 'Mousse Cacao'
put 'products', 'product#pastry011', 'info:description', 'Mousse cacao nguyên chất, mềm mịn tan chảy, hương vị đậm đà'
put 'products', 'product#pastry011', 'info:price', '52000'
put 'products', 'product#pastry011', 'info:category', 'pastry'
put 'products', 'product#pastry011', 'info:isAvailable', 'true'
put 'products', 'product#pastry011', 'info:preparationTime', '5'
put 'products', 'product#pastry011', 'info:rating', '4.5'
put 'products', 'product#pastry011', 'info:reviewCount', '0'
put 'products', 'product#pastry011', 'info:imageUrl', 'https://images.unsplash.com/photo-1586985289688-ca3cf47d3e6e'
put 'products', 'product#pastry011', 'info:createdAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry011', 'info:updatedAt', '2024-01-01T00:00:00Z'
put 'products', 'product#pastry011', 'options:sizes', '["Standard"]'
put 'products', 'product#pastry011', 'options:options', '[{"name":"Topping","choices":["Không","Whipped Cream","Chocolate Chips","Gold Leaf"]}]'

"@

# Save commands to file
$tempFile = "hbase_new_pastries.txt"
$hbaseCommands | Out-File -FilePath $tempFile -Encoding UTF8

Write-Host "✓ Đã tạo file lệnh HBase: $tempFile" -ForegroundColor Green
Write-Host ""

# Display summary
Write-Host "Bánh ngọt mới được thêm:" -ForegroundColor Cyan
Write-Host "  1. Bánh Su Kem (pastry007) - 38,000₫" -ForegroundColor White
Write-Host "  2. Bánh Sữa Chua Phô Mai (pastry008) - 45,000₫" -ForegroundColor White
Write-Host "  3. Bánh Phô Mai Trà Xanh (pastry009) - 48,000₫" -ForegroundColor White
Write-Host "  4. Bánh Phô Mai Chanh Dây (pastry010) - 48,000₫" -ForegroundColor White
Write-Host "  5. Mousse Cacao (pastry011) - 52,000₫" -ForegroundColor White
Write-Host ""
Write-Host "Lưu ý: Bánh Tiramisu (pastry003) đã có sẵn trong hệ thống!" -ForegroundColor Yellow
Write-Host ""

# Check if HBase is available
try {
    $hbaseVersion = hbase version 2>$null
    if ($hbaseVersion) {
        Write-Host "✓ HBase khả dụng" -ForegroundColor Green
        Write-Host ""
        
        # Ask for confirmation
        $confirmation = Read-Host "Bạn có muốn thêm các sản phẩm này vào HBase ngay bây giờ? (y/n)"
        
        if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
            Write-Host "Đang thêm bánh ngọt vào HBase..." -ForegroundColor Yellow
            hbase shell $tempFile
            
            Write-Host ""
            Write-Host "✓ Đã thêm bánh ngọt thành công!" -ForegroundColor Green
        } else {
            Write-Host "Đã hủy. Bạn có thể chạy lại script này sau." -ForegroundColor Yellow
        }
    } else {
        Write-Host "✗ HBase không khả dụng. Vui lòng đảm bảo HBase đã được cài đặt và trong PATH." -ForegroundColor Red
        Write-Host ""
        Write-Host "Bạn có thể chạy lệnh thủ công bằng cách:" -ForegroundColor Yellow
        Write-Host "1. Khởi động HBase shell: hbase shell" -ForegroundColor Cyan
        Write-Host "2. Copy-paste các lệnh từ file $tempFile" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ Lỗi khi kiểm tra HBase: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Bạn có thể chạy lệnh thủ công bằng cách:" -ForegroundColor Yellow
    Write-Host "1. Khởi động HBase shell: hbase shell" -ForegroundColor Cyan
    Write-Host "2. Copy-paste các lệnh từ file $tempFile" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Hoàn tất!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""






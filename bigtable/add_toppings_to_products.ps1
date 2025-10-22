# Script để thêm topping vào sản phẩm Highlands Coffee
# Run: .\bigtable\add_toppings_to_products.ps1

Write-Host "=== Thêm Topping vào Sản phẩm Highlands ===" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:8080/api"

# Định nghĩa các loại topping với giá
$toppings = @(
    @{
        id = "topping_hat_sen"
        name = "Hạt Sen"
        price = 10000
        imageUrl = "https://product.hstatic.net/200000464613/product/hat-sen_32ad99c28a0847a19ff51ea30b1d3f86_grande.jpg"
        isAvailable = $true
    },
    @{
        id = "topping_cu_nang"
        name = "Củ Năng"
        price = 10000
        imageUrl = "https://product.hstatic.net/200000464613/product/cu-nang_f0fd6cdeb7da468488107e5d794e8580_grande.jpg"
        isAvailable = $true
    },
    @{
        id = "topping_thach_dao"
        name = "Thạch Đào"
        price = 10000
        imageUrl = "https://product.hstatic.net/200000464613/product/thach-dao_35fc2e4e372e4a7fb30dfb77f0fcc0e0_grande.jpg"
        isAvailable = $true
    },
    @{
        id = "topping_thach_vai"
        name = "Thạch Vải"
        price = 10000
        imageUrl = "https://product.hstatic.net/200000464613/product/thach-vai_69c8b6e6d5b74b6ab2f6f3f94f7b9e8d_grande.jpg"
        isAvailable = $true
    },
    @{
        id = "topping_thach_tra"
        name = "Thạch Trà / Thạch Sô-cô-la"
        price = 10000
        imageUrl = "https://product.hstatic.net/200000464613/product/thach-tra_f31a6b4d90f8466e9fc7b87d67a3c8f2_grande.jpg"
        isAvailable = $true
    },
    @{
        id = "topping_tran_chau_dua"
        name = "Trân Châu Dừa"
        price = 10000
        imageUrl = "https://product.hstatic.net/200000464613/product/tran-chau-dua_e8c9b5c1f4e94c9b9f6c8a7e3f2d1c0b_grande.jpg"
        isAvailable = $true
    },
    @{
        id = "topping_tran_chau_khoai_mon"
        name = "Trân Châu Khoai Môn"
        price = 10000
        imageUrl = "https://product.hstatic.net/200000464613/product/tran-chau-khoai-mon_d7c5b3a1e9f84b6a8e5d7c9f1a2b3c4d_grande.jpg"
        isAvailable = $true
    },
    @{
        id = "topping_kem_whip"
        name = "Kem Whip (Kem tươi)"
        price = 15000
        imageUrl = "https://product.hstatic.net/200000464613/product/kem-tuoi_a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3_grande.jpg"
        isAvailable = $true
    }
)

Write-Host "Danh sách topping sẽ được thêm:" -ForegroundColor Cyan
foreach ($topping in $toppings) {
    $priceFormatted = "{0:N0}" -f $topping.price
    Write-Host "  - $($topping.name): ${priceFormatted}đ" -ForegroundColor White
}
Write-Host ""

# Function để gọi API
function Update-ProductToppings {
    param(
        [string]$ProductId,
        [array]$Toppings,
        [string]$Token
    )
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        if ($Token) {
            $headers["Authorization"] = "Bearer $Token"
        }
        
        $body = @{
            availableToppings = $Toppings
        } | ConvertTo-Json -Depth 10
        
        $response = Invoke-RestMethod `
            -Uri "$baseUrl/products/$ProductId" `
            -Method PUT `
            -Headers $headers `
            -Body $body
        
        return $response
    } catch {
        Write-Host "Lỗi khi cập nhật product $ProductId : $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Lấy danh sách sản phẩm
Write-Host "Đang lấy danh sách sản phẩm..." -ForegroundColor Yellow
try {
    $products = Invoke-RestMethod -Uri "$baseUrl/products" -Method GET
    Write-Host "Tìm thấy $($products.Count) sản phẩm" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "Không thể lấy danh sách sản phẩm. Vui lòng kiểm tra backend đã chạy chưa." -ForegroundColor Red
    exit 1
}

# Lọc sản phẩm có thể thêm topping (coffee, tea, freeze)
$eligibleCategories = @('coffee', 'tea', 'freeze')
$productsToUpdate = $products | Where-Object { $eligibleCategories -contains $_.category }

Write-Host "Sẽ thêm topping vào $($productsToUpdate.Count) sản phẩm (coffee, tea, freeze)" -ForegroundColor Cyan
Write-Host ""

# Xác nhận
$confirmation = Read-Host "Bạn có muốn tiếp tục? (y/n)"
if ($confirmation -ne 'y') {
    Write-Host "Đã hủy!" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Bắt đầu cập nhật sản phẩm..." -ForegroundColor Green
Write-Host ""

$successCount = 0
$failCount = 0

foreach ($product in $productsToUpdate) {
    Write-Host "Đang cập nhật: $($product.name)..." -ForegroundColor Yellow
    
    $result = Update-ProductToppings -ProductId $product.id -Toppings $toppings
    
    if ($result) {
        Write-Host "  ✓ Thành công!" -ForegroundColor Green
        $successCount++
    } else {
        Write-Host "  ✗ Thất bại!" -ForegroundColor Red
        $failCount++
    }
    
    Start-Sleep -Milliseconds 200
}

Write-Host ""
Write-Host "=== Hoàn thành ===" -ForegroundColor Green
Write-Host "Thành công: $successCount sản phẩm" -ForegroundColor Green
Write-Host "Thất bại: $failCount sản phẩm" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
Write-Host ""
Write-Host "Topping đã được thêm vào các sản phẩm coffee, tea, và freeze!" -ForegroundColor Cyan


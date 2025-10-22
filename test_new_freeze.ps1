# Test New Freeze Products
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  KIEM TRA FREEZE MOI" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:8080/api"

# Login
Write-Host "1. Dang nhap..." -ForegroundColor Yellow
$loginData = @{
    email = "admin@highlands.vn"
    password = "admin123"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
$token = $loginResponse.data.token
Write-Host "   OK!" -ForegroundColor Green

# Clear cache
Write-Host "2. Xoa cache..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
}

Invoke-RestMethod -Uri "$baseUrl/admin/cache/clear" -Method POST -Headers $headers | Out-Null
Write-Host "   Cache da xoa!" -ForegroundColor Green

# Get freeze products
Write-Host "3. Lay danh sach Freeze..." -ForegroundColor Yellow
Start-Sleep -Seconds 1

$products = Invoke-RestMethod -Uri "$baseUrl/products?category=freeze" -Method GET -Headers $headers

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "TONG SO FREEZE: $($products.data.count)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Display all
$oldCount = 0
$newCount = 0

foreach ($p in $products.data.products) {
    $price = "{0:N0}" -f $p.price
    $hasImage = if ($p.imageUrl -and $p.imageUrl -ne '') { "[IMG]" } else { "[---]" }
    
    if ($p.id -match "frz00[6-8]") {
        Write-Host "  $hasImage $($p.name) - ${price}d [MOI]" -ForegroundColor Green
        $newCount++
    } else {
        Write-Host "  $hasImage $($p.name) - ${price}d" -ForegroundColor White
        $oldCount++
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "TONG KET:" -ForegroundColor Cyan
Write-Host "  - Freeze cu: $oldCount" -ForegroundColor White
Write-Host "  - Freeze moi: $newCount" -ForegroundColor Green
Write-Host "  - Tong cong: $($products.data.count)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

if ($products.data.count -eq 8 -and $newCount -eq 3) {
    Write-Host "THANH CONG! Da them 3 Freeze moi!" -ForegroundColor Green
    Write-Host ""
    Write-Host "DANH SACH FREEZE MOI:" -ForegroundColor Yellow
    Write-Host "  1. Freeze Tra Xanh - 52,000d" -ForegroundColor Green
    Write-Host "  2. Freeze So-Co-La - 55,000d" -ForegroundColor Green
    Write-Host "  3. Freeze Kem May Dau Tam - 58,000d" -ForegroundColor Green
} else {
    Write-Host "CHU Y: Mong doi 8 freeze (3 moi)" -ForegroundColor Yellow
    Write-Host "Thuc te: $($products.data.count) freeze ($newCount moi)" -ForegroundColor White
}

Write-Host ""
Write-Host "BUOC TIEP THEO:" -ForegroundColor Yellow
Write-Host "1. Mo Flutter app" -ForegroundColor Cyan
Write-Host "2. Nhan Shift+R de Hot Restart" -ForegroundColor Cyan
Write-Host "3. Vao muc 'Freeze' de xem!" -ForegroundColor Cyan
Write-Host ""



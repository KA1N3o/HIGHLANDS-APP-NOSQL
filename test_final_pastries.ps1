# Final Test - Banh Ngot Moi
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  KIEM TRA CUOI CUNG - BANH NGOT MOI" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:8080/api"

# Login
$loginData = @{
    email = "admin@highlands.vn"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    $token = $loginResponse.data.token
} catch {
    Write-Host "Loi dang nhap!" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
}

# Get products
$products = Invoke-RestMethod -Uri "$baseUrl/products?category=pastry" -Method GET -Headers $headers

Write-Host "TONG SO BANH NGOT: $($products.data.count)" -ForegroundColor Cyan
Write-Host ""

# Display all
Write-Host "DANH SACH DAY DU:" -ForegroundColor Yellow
Write-Host "------------------------------------------" -ForegroundColor Gray

$oldCount = 0
$newCount = 0

foreach ($p in $products.data.products) {
    $price = "{0:N0}" -f $p.price
    $hasImage = if ($p.imageUrl -and $p.imageUrl -ne '') { "[IMG]" } else { "[---]" }
    
    if ($p.id -match "pastry00[7-9]|pastry01[0-1]") {
        Write-Host "  $hasImage $($p.name) - ${price}d [MOI]" -ForegroundColor Green
        $newCount++
    } else {
        Write-Host "  $hasImage $($p.name) - ${price}d" -ForegroundColor White
        $oldCount++
    }
}

Write-Host "------------------------------------------" -ForegroundColor Gray
Write-Host ""

# Summary
Write-Host "TONG KET:" -ForegroundColor Cyan
Write-Host "  - Banh cu: $oldCount" -ForegroundColor White
Write-Host "  - Banh moi: $newCount" -ForegroundColor Green
Write-Host "  - Tong cong: $($products.data.count)" -ForegroundColor Cyan
Write-Host ""

if ($products.data.count -eq 11 -and $newCount -eq 5) {
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "  THANH CONG! TAT CA DA SAN SANG!" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "BUOC TIEP THEO:" -ForegroundColor Yellow
    Write-Host "1. Mo Flutter app" -ForegroundColor Cyan
    Write-Host "2. Nhan Shift+R de Hot Restart" -ForegroundColor Cyan
    Write-Host "3. Vao muc 'Banh Ngot' de xem!" -ForegroundColor Cyan
} else {
    Write-Host "=========================================" -ForegroundColor Yellow
    Write-Host "  CHU Y: CO VAI VAN DE!" -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Yellow
    Write-Host "Mong doi: 11 banh ngot (5 moi)" -ForegroundColor White
    Write-Host "Thuc te: $($products.data.count) banh ngot ($newCount moi)" -ForegroundColor White
}

Write-Host ""



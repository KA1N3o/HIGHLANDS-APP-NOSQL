# Test Banh Mi Update
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  KIEM TRA CAP NHAT BANH MI" -ForegroundColor Green
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

$headers = @{
    "Authorization" = "Bearer $token"
}

# Clear cache
Write-Host "2. Xoa cache..." -ForegroundColor Yellow
Invoke-RestMethod -Uri "$baseUrl/admin/cache/clear" -Method POST -Headers $headers | Out-Null
Write-Host "   Cache da xoa!" -ForegroundColor Green

Write-Host "3. Kiem tra categories..." -ForegroundColor Yellow
Start-Sleep -Seconds 1

# Get categories
$categories = Invoke-RestMethod -Uri "$baseUrl/products/categories" -Method GET -Headers $headers

Write-Host ""
Write-Host "DANH MUC SAN PHAM:" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Gray
foreach ($cat in $categories.data) {
    Write-Host "  $($cat.icon) $($cat.name) (id: $($cat.id))" -ForegroundColor White
}
Write-Host "==========================================" -ForegroundColor Gray

# Get food products
Write-Host ""
Write-Host "4. Kiem tra san pham BANH MI..." -ForegroundColor Yellow
$foodProducts = Invoke-RestMethod -Uri "$baseUrl/products?category=food" -Method GET -Headers $headers

Write-Host ""
Write-Host "SAN PHAM BANH MI ($($foodProducts.data.count) san pham):" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Gray
foreach ($p in $foodProducts.data.products) {
    $price = "{0:N0}" -f $p.price
    Write-Host "  - $($p.name) - ${price}d" -ForegroundColor White
}
Write-Host "==========================================" -ForegroundColor Gray

# Get pastry products
Write-Host ""
Write-Host "5. Kiem tra san pham BANH NGOT..." -ForegroundColor Yellow
$pastryProducts = Invoke-RestMethod -Uri "$baseUrl/products?category=pastry" -Method GET -Headers $headers

Write-Host ""
Write-Host "SAN PHAM BANH NGOT ($($pastryProducts.data.count) san pham):" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Gray
foreach ($p in $pastryProducts.data.products) {
    $price = "{0:N0}" -f $p.price
    Write-Host "  - $($p.name) - ${price}d" -ForegroundColor White
}
Write-Host "==========================================" -ForegroundColor Gray

Write-Host ""
Write-Host "TONG KET:" -ForegroundColor Yellow
Write-Host "  - Banh Mi: $($foodProducts.data.count) san pham" -ForegroundColor White
Write-Host "  - Banh Ngot: $($pastryProducts.data.count) san pham" -ForegroundColor White

Write-Host ""
if ($foodProducts.data.count -eq 5 -and $pastryProducts.data.count -eq 9) {
    Write-Host "THANH CONG!" -ForegroundColor Green
    Write-Host "- 2 Croissant da chuyen sang Banh Mi!" -ForegroundColor Green
    Write-Host "- Tab 'Do An' da doi thanh 'Banh Mi'!" -ForegroundColor Green
} else {
    Write-Host "Mong doi: 5 banh mi, 9 banh ngot" -ForegroundColor Yellow
    Write-Host "Thuc te: $($foodProducts.data.count) banh mi, $($pastryProducts.data.count) banh ngot" -ForegroundColor White
}

Write-Host ""
Write-Host "BUOC TIEP THEO:" -ForegroundColor Yellow
Write-Host "1. Mo Flutter app" -ForegroundColor Cyan
Write-Host "2. Nhan Shift+R de Hot Restart" -ForegroundColor Cyan
Write-Host "3. Kiem tra tab 'Banh Mi' va 'Banh Ngot'!" -ForegroundColor Cyan
Write-Host ""


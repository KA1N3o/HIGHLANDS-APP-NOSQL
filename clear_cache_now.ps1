# Clear Cache
$baseUrl = "http://localhost:8080/api"

Write-Host "Dang nhap..." -ForegroundColor Yellow
$loginData = @{
    email = "admin@highlands.vn"
    password = "admin123"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
$token = $loginResponse.data.token

Write-Host "Xoa cache..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
}

try {
    Invoke-RestMethod -Uri "$baseUrl/admin/cache/clear" -Method POST -Headers $headers
    Write-Host "Cache da duoc xoa!" -ForegroundColor Green
} catch {
    Write-Host "Endpoint cache/clear chua co. Restart backend de ap dung code moi." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Kiem tra banh ngot..." -ForegroundColor Yellow
Start-Sleep -Seconds 1

$products = Invoke-RestMethod -Uri "$baseUrl/products?category=pastry" -Method GET -Headers $headers

Write-Host "Tim thay: $($products.data.count) banh ngot" -ForegroundColor Cyan
Write-Host ""

foreach ($product in $products.data.products) {
    $hasImage = if ($product.imageUrl -and $product.imageUrl -ne '') { "OK" } else { "NO IMAGE" }
    Write-Host "$($product.name) - $hasImage - $($product.imageUrl)" -ForegroundColor White
}

Write-Host ""
if ($products.data.count -ge 11) {
    Write-Host "THANH CONG! Co $($products.data.count) banh ngot!" -ForegroundColor Green
} else {
    Write-Host "Cache chua clear. Restart backend (Ctrl+C trong terminal backend, roi npm start)" -ForegroundColor Yellow
}



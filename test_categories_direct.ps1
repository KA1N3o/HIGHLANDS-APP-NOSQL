# Test Categories Direct
Write-Host "Test Categories API..." -ForegroundColor Yellow
Write-Host ""

$baseUrl = "http://localhost:8080/api"

# Login
$loginData = @{
    email = "admin@highlands.vn"
    password = "admin123"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
$token = $loginResponse.data.token

$headers = @{
    "Authorization" = "Bearer $token"
}

# Get categories
Write-Host "Dang lay categories..." -ForegroundColor Cyan
$response = Invoke-RestMethod -Uri "$baseUrl/products/categories" -Method GET -Headers $headers

Write-Host ""
Write-Host "KET QUA TRA VE TU API:" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Gray

foreach ($cat in $response.data) {
    $colorName = if ($cat.id -eq 'food') { "Yellow" } else { "White" }
    Write-Host "  ID: $($cat.id)" -ForegroundColor $colorName
    Write-Host "  Name: $($cat.name)" -ForegroundColor $colorName
    Write-Host "  Icon: $($cat.icon)" -ForegroundColor $colorName
    Write-Host "  ---" -ForegroundColor Gray
}

Write-Host "========================================" -ForegroundColor Gray
Write-Host ""

# Check specifically
$foodCat = $response.data | Where-Object { $_.id -eq 'food' }
if ($foodCat) {
    if ($foodCat.name -eq 'Bánh Mì') {
        Write-Host "THANH CONG! Backend da tra ve 'Banh Mi'" -ForegroundColor Green
    } else {
        Write-Host "CHU Y: Backend van tra ve '$($foodCat.name)'" -ForegroundColor Red
        Write-Host "Kiem tra xem backend da restart chua?" -ForegroundColor Yellow
    }
}


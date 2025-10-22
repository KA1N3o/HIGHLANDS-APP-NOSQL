# Test Caramel Coffee Freeze Image
Write-Host "========================================" -ForegroundColor Green
Write-Host "Test Caramel Coffee Freeze Image" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:8080/api"

# Login
Write-Host "Dang nhap..." -ForegroundColor Yellow
$loginData = @{
    email = "admin@highlands.vn"
    password = "admin123"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
$token = $loginResponse.data.token

# Clear cache
Write-Host "Xoa cache..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
}

Invoke-RestMethod -Uri "$baseUrl/admin/cache/clear" -Method POST -Headers $headers | Out-Null
Write-Host "Cache da xoa!" -ForegroundColor Green

# Get product
Write-Host "Kiem tra san pham..." -ForegroundColor Yellow
Start-Sleep -Seconds 1

$products = Invoke-RestMethod -Uri "$baseUrl/products?category=freeze" -Method GET -Headers $headers

$caramelFreeze = $products.data.products | Where-Object { $_.id -eq "product#frz001" }

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
if ($caramelFreeze) {
    Write-Host "San pham: $($caramelFreeze.name)" -ForegroundColor White
    Write-Host "Gia: $($caramelFreeze.price)d" -ForegroundColor White
    Write-Host "Image URL: $($caramelFreeze.imageUrl)" -ForegroundColor Gray
    
    # Test URL
    Write-Host ""
    Write-Host "Test URL..." -ForegroundColor Yellow
    try {
        $testUrl = Invoke-WebRequest -Uri $caramelFreeze.imageUrl -Method Head -TimeoutSec 5 -UseBasicParsing
        if ($testUrl.StatusCode -eq 200) {
            Write-Host "URL hoat dong TOT! (200 OK)" -ForegroundColor Green
        } else {
            Write-Host "URL status: $($testUrl.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "URL LOI: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "KHONG TIM THAY Caramel Coffee Freeze!" -ForegroundColor Red
}
Write-Host "========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "BUOC TIEP THEO:" -ForegroundColor Yellow
Write-Host "1. Mo Flutter app" -ForegroundColor Cyan
Write-Host "2. Nhan Shift+R de Hot Restart" -ForegroundColor Cyan
Write-Host "3. Kiem tra hinh anh Caramel Coffee Freeze!" -ForegroundColor Cyan
Write-Host ""


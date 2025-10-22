# Fix 2 Images - Banh Su Kem & Banh Pho Mai Chanh Day
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Fix Hinh Anh 2 Banh" -ForegroundColor Green
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

try {
    Invoke-RestMethod -Uri "$baseUrl/admin/cache/clear" -Method POST -Headers $headers | Out-Null
    Write-Host "   Cache da xoa!" -ForegroundColor Green
} catch {
    Write-Host "   Khong xoa duoc cache" -ForegroundColor Yellow
}

Write-Host "3. Kiem tra 2 banh..." -ForegroundColor Yellow
Start-Sleep -Seconds 1

# Get products
$products = Invoke-RestMethod -Uri "$baseUrl/products?category=pastry" -Method GET -Headers $headers

# Find the 2 pastries
$pastry007 = $products.data.products | Where-Object { $_.id -eq "product#pastry007" }
$pastry010 = $products.data.products | Where-Object { $_.id -eq "product#pastry010" }

Write-Host ""
Write-Host "KET QUA:" -ForegroundColor Cyan
Write-Host "------------------------------------------" -ForegroundColor Gray

if ($pastry007) {
    $hasImg007 = if ($pastry007.imageUrl -and $pastry007.imageUrl -ne '') { "OK" } else { "MISSING" }
    Write-Host "Banh Su Kem:" -ForegroundColor White
    Write-Host "  - Image: $hasImg007" -ForegroundColor $(if ($hasImg007 -eq "OK") { "Green" } else { "Red" })
    Write-Host "  - URL: $($pastry007.imageUrl)" -ForegroundColor Gray
} else {
    Write-Host "Banh Su Kem: KHONG TIM THAY!" -ForegroundColor Red
}

Write-Host ""

if ($pastry010) {
    $hasImg010 = if ($pastry010.imageUrl -and $pastry010.imageUrl -ne '') { "OK" } else { "MISSING" }
    Write-Host "Banh Pho Mai Chanh Day:" -ForegroundColor White
    Write-Host "  - Image: $hasImg010" -ForegroundColor $(if ($hasImg010 -eq "OK") { "Green" } else { "Red" })
    Write-Host "  - URL: $($pastry010.imageUrl)" -ForegroundColor Gray
} else {
    Write-Host "Banh Pho Mai Chanh Day: KHONG TIM THAY!" -ForegroundColor Red
}

Write-Host "------------------------------------------" -ForegroundColor Gray
Write-Host ""

# Test URLs
Write-Host "4. Test URL truc tiep..." -ForegroundColor Yellow

if ($pastry007 -and $pastry007.imageUrl) {
    try {
        $test007 = Invoke-WebRequest -Uri $pastry007.imageUrl -Method Head -TimeoutSec 5 -UseBasicParsing
        if ($test007.StatusCode -eq 200) {
            Write-Host "   Banh Su Kem URL: OK (200)" -ForegroundColor Green
        } else {
            Write-Host "   Banh Su Kem URL: Status $($test007.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   Banh Su Kem URL: LOI - $($_.Exception.Message)" -ForegroundColor Red
    }
}

if ($pastry010 -and $pastry010.imageUrl) {
    try {
        $test010 = Invoke-WebRequest -Uri $pastry010.imageUrl -Method Head -TimeoutSec 5 -UseBasicParsing
        if ($test010.StatusCode -eq 200) {
            Write-Host "   Banh Pho Mai Chanh Day URL: OK (200)" -ForegroundColor Green
        } else {
            Write-Host "   Banh Pho Mai Chanh Day URL: Status $($test010.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   Banh Pho Mai Chanh Day URL: LOI - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "BUOC TIEP THEO:" -ForegroundColor Yellow
Write-Host "1. Mo Flutter app" -ForegroundColor Cyan
Write-Host "2. Nhan Shift+R (Hot Restart)" -ForegroundColor Cyan
Write-Host "3. Kiem tra lai 2 banh!" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""


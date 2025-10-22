# Test Sau Khi Restart Backend
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Kiem Tra Banh Ngot Sau Restart" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:8080/api"

# Test backend
Write-Host "Kiem tra backend..." -ForegroundColor Yellow
try {
    $test = Invoke-RestMethod -Uri "http://localhost:8080" -TimeoutSec 5
    Write-Host "Backend dang chay!" -ForegroundColor Green
} catch {
    Write-Host "Backend chua chay! Vui long khoi dong backend." -ForegroundColor Red
    Write-Host "Chay: cd backend && npm start" -ForegroundColor Cyan
    exit 1
}

Write-Host ""

# Login
Write-Host "Dang nhap..." -ForegroundColor Yellow
$loginData = @{
    email = "admin@highlands.vn"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    $token = $loginResponse.data.token
    Write-Host "Thanh cong!" -ForegroundColor Green
} catch {
    Write-Host "Loi dang nhap!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Get pastry products
Write-Host "Lay danh sach banh ngot..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
}

try {
    $products = Invoke-RestMethod -Uri "$baseUrl/products?category=pastry" -Method GET -Headers $headers
    
    Write-Host ""
    Write-Host "===================================" -ForegroundColor Cyan
    Write-Host "KET QUA: Tim thay $($products.data.count) banh ngot" -ForegroundColor Cyan
    Write-Host "===================================" -ForegroundColor Cyan
    Write-Host ""
    
    $count = 0
    foreach ($product in $products.data.products) {
        $count++
        $priceFormatted = "{0:N0}" -f $product.price
        $isNew = $product.id -match "pastry00[7-9]|pastry01[0-1]"
        
        if ($isNew) {
            Write-Host "  $count. $($product.name) - ${priceFormatted}VND [MOI]" -ForegroundColor Green
        } else {
            Write-Host "  $count. $($product.name) - ${priceFormatted}VND" -ForegroundColor White
        }
    }
    
    Write-Host ""
    Write-Host "===================================" -ForegroundColor Cyan
    
    $newCount = ($products.data.products | Where-Object { $_.id -match "pastry00[7-9]|pastry01[0-1]" }).Count
    
    if ($products.data.count -ge 11 -and $newCount -ge 5) {
        Write-Host "THANH CONG!" -ForegroundColor Green
        Write-Host "Da them thanh cong 5 banh ngot moi!" -ForegroundColor Green
        Write-Host "Tong: $($products.data.count) banh ngot ($newCount banh moi)" -ForegroundColor Green
    } elseif ($products.data.count -eq 6) {
        Write-Host "CACHE CHUA HET HAN!" -ForegroundColor Yellow
        Write-Host "Vui long:" -ForegroundColor Yellow
        Write-Host "- Restart backend (Ctrl+C roi npm start)" -ForegroundColor Cyan
        Write-Host "- Hoac doi them 10 phut de cache tu dong xoa" -ForegroundColor Cyan
    } else {
        Write-Host "CO MOT VAI BANH MOI!" -ForegroundColor Yellow
        Write-Host "Tim thay: $newCount/5 banh moi" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Loi: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""



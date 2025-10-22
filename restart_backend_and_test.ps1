# Restart Backend and Test
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Restart Backend & Test Banh Ngot" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

Write-Host "LUU Y: Vui long restart backend theo cach sau:" -ForegroundColor Yellow
Write-Host "1. Nhan Ctrl+C o terminal dang chay backend" -ForegroundColor Cyan
Write-Host "2. Chay lai: npm start (trong thu muc backend)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Hoac chay: .\start_backend.bat" -ForegroundColor Cyan
Write-Host ""
Write-Host "Sau khi restart, chay lai script nay!" -ForegroundColor Yellow
Write-Host ""

# Wait for user confirmation
$confirm = Read-Host "Da restart backend chua? (y/n)"

if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "Vui long restart backend truoc!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Dang kiem tra backend..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

$baseUrl = "http://localhost:8080/api"

# Test backend
try {
    $test = Invoke-RestMethod -Uri "http://localhost:8080"
    Write-Host "Backend dang chay!" -ForegroundColor Green
} catch {
    Write-Host "Backend chua chay!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Login
Write-Host "Dang dang nhap..." -ForegroundColor Yellow
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
Write-Host "Dang lay danh sach banh ngot..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
}

try {
    $products = Invoke-RestMethod -Uri "$baseUrl/products?category=pastry" -Method GET -Headers $headers
    
    Write-Host "Tim thay $($products.data.count) banh ngot!" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($product in $products.data.products) {
        $priceFormatted = "{0:N0}" -f $product.price
        Write-Host "  $($product.name) - ${priceFormatted}VND" -ForegroundColor White
    }
    
    Write-Host ""
    
    if ($products.data.count -ge 11) {
        Write-Host "THANH CONG! Co $($products.data.count) banh ngot (bao gom 5 banh moi)!" -ForegroundColor Green
    } else {
        Write-Host "CHU Y: Chi co $($products.data.count) banh ngot!" -ForegroundColor Yellow
        Write-Host "Cache co the chua duoc clear. Doi 10 phut hoac restart backend!" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Loi khi lay san pham!" -ForegroundColor Red
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""



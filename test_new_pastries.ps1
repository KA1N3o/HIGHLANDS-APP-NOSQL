# Test Bánh Ngọt Mới
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Kiem Tra Banh Ngot Moi" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:8080/api"

# Login to get token
Write-Host "Dang dang nhap..." -ForegroundColor Yellow
$loginData = @{
    email = "admin@highlands.vn"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    $token = $loginResponse.data.token
    Write-Host "Dang nhap thanh cong!" -ForegroundColor Green
} catch {
    Write-Host "Loi dang nhap" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Get all pastry products
Write-Host "Dang lay danh sach banh ngot..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
}

try {
    $products = Invoke-RestMethod -Uri "$baseUrl/products?category=pastry" -Method GET -Headers $headers
    
    Write-Host "Tim thay $($products.data.count) banh ngot:" -ForegroundColor Green
    Write-Host ""
    
    foreach ($product in $products.data.products) {
        $priceFormatted = "{0:N0}" -f $product.price
        Write-Host "  - $($product.name) ($($product.id)) - ${priceFormatted}VND" -ForegroundColor Cyan
    }
    
    Write-Host ""
    Write-Host "Kiem tra cac banh moi:" -ForegroundColor Yellow
    
    $newPastries = @("pastry007", "pastry008", "pastry009", "pastry010", "pastry011")
    $newPastryNames = @("Banh Su Kem", "Banh Sua Chua Pho Mai", "Banh Pho Mai Tra Xanh", "Banh Pho Mai Chanh Day", "Mousse Cacao")
    
    for ($i = 0; $i -lt $newPastries.Length; $i++) {
        $id = "product#$($newPastries[$i])"
        $found = $false
        foreach ($p in $products.data.products) {
            if ($p.id -eq $id) {
                $found = $true
                break
            }
        }
        
        if ($found) {
            Write-Host "  OK - $($newPastryNames[$i]) - DA CO" -ForegroundColor Green
        } else {
            Write-Host "  X  - $($newPastryNames[$i]) - CHUA CO" -ForegroundColor Red
        }
    }
    
} catch {
    Write-Host "Loi khi lay san pham" -ForegroundColor Red
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Hoan tat kiem tra!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

# Clear Cache and Test New Pastries
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Clear Cache & Test Banh Ngot Moi" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:8080/api"

# Login
Write-Host "1. Dang dang nhap..." -ForegroundColor Yellow
$loginData = @{
    email = "admin@highlands.vn"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    $token = $loginResponse.data.token
    Write-Host "   Thanh cong!" -ForegroundColor Green
} catch {
    Write-Host "   Loi!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Clear cache
Write-Host "2. Dang xoa cache..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
}

try {
    $clearResponse = Invoke-RestMethod -Uri "$baseUrl/admin/cache/clear" -Method POST -Headers $headers
    Write-Host "   Cache da duoc xoa!" -ForegroundColor Green
} catch {
    Write-Host "   Loi khi xoa cache: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Get pastry products
Write-Host "3. Dang kiem tra banh ngot..." -ForegroundColor Yellow
Start-Sleep -Seconds 1

try {
    $products = Invoke-RestMethod -Uri "$baseUrl/products?category=pastry" -Method GET -Headers $headers
    
    Write-Host "   Tim thay $($products.data.count) banh ngot!" -ForegroundColor Green
    Write-Host ""
    
    foreach ($product in $products.data.products) {
        $priceFormatted = "{0:N0}" -f $product.price
        Write-Host "   - $($product.name) - ${priceFormatted}VND" -ForegroundColor Cyan
    }
    
    Write-Host ""
    Write-Host "Kiem tra 5 banh moi:" -ForegroundColor Yellow
    
    $newPastryIds = @("product#pastry007", "product#pastry008", "product#pastry009", "product#pastry010", "product#pastry011")
    $newPastryNames = @("Banh Su Kem", "Banh Sua Chua Pho Mai", "Banh Pho Mai Tra Xanh", "Banh Pho Mai Chanh Day", "Mousse Cacao")
    
    $foundCount = 0
    for ($i = 0; $i -lt $newPastryIds.Length; $i++) {
        $found = $false
        foreach ($p in $products.data.products) {
            if ($p.id -eq $newPastryIds[$i]) {
                $found = $true
                $foundCount++
                break
            }
        }
        
        if ($found) {
            Write-Host "   OK - $($newPastryNames[$i])" -ForegroundColor Green
        } else {
            Write-Host "   X  - $($newPastryNames[$i])" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    if ($foundCount -eq 5) {
        Write-Host "THANH CONG! Tat ca 5 banh moi da duoc them!" -ForegroundColor Green
    } else {
        Write-Host "CHU Y: Chi co $foundCount/5 banh moi!" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "   Loi!" -ForegroundColor Red
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Hoan tat!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""






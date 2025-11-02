# Script to update some products to be available
Write-Host "Updating products to be available..." -ForegroundColor Green

$baseUrl = "http://localhost:8080/api"

# Login as admin
Write-Host "Logging in as admin..." -ForegroundColor Yellow
$loginData = @{
    email = "admin@highlands.vn"
    password = "admin123"
} | ConvertTo-Json

$loginResponse = Invoke-WebRequest -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
$loginResult = $loginResponse.Content | ConvertFrom-Json

if ($loginResult.success) {
    $token = $loginResult.data.token
    Write-Host "Login successful! Token: $($token.Substring(0, 20))..." -ForegroundColor Green
    
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    # List of products to make available
    $productsToUpdate = @(
        "product#cf001",
        "product#cf002", 
        "product#cf003",
        "product#esp001",
        "product#esp002",
        "product#food001",
        "product#food002",
        "product#pastry001",
        "product#pastry002",
        "product#tea001"
    )
    
    foreach ($productId in $productsToUpdate) {
        Write-Host "Updating $productId..." -ForegroundColor Yellow
        
        $updateData = @{
            isAvailable = $true
        } | ConvertTo-Json
        
        try {
            $response = Invoke-WebRequest -Uri "$baseUrl/admin/products/$productId" -Method PUT -Body $updateData -ContentType "application/json" -Headers $headers
            Write-Host "Updated $productId successfully" -ForegroundColor Green
        } catch {
            Write-Host "Failed to update $productId : $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host "Product availability update completed!" -ForegroundColor Green
} else {
    Write-Host "Failed to login as admin" -ForegroundColor Red
}






















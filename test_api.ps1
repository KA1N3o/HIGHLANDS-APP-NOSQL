# Highlands Coffee - Backend API Test Script

Write-Host "Testing Highlands Coffee Backend API..." -ForegroundColor Green

$baseUrl = "http://localhost:8080/api"

# Test Health Check
Write-Host "1. Health Check..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing
    $healthResult = $healthResponse.Content | ConvertFrom-Json
    Write-Host "   Backend is running: $($healthResult.message)" -ForegroundColor Green
} catch {
    Write-Host "   Backend is not running!" -ForegroundColor Red
    exit 1
}

# Test Admin Login
Write-Host "2. Admin Login..." -ForegroundColor Yellow
try {
    $loginData = '{"email":"admin@highlands.vn","password":"admin123"}'
    $loginResponse = Invoke-WebRequest -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json" -UseBasicParsing
    $loginResult = $loginResponse.Content | ConvertFrom-Json
    
    if ($loginResult.success) {
        $token = $loginResult.data.token
        $userRole = $loginResult.data.user.role
        Write-Host "   Login successful" -ForegroundColor Green
        Write-Host "   User Role: $userRole" -ForegroundColor Cyan
    } else {
        Write-Host "   Login failed!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   Login error!" -ForegroundColor Red
    exit 1
}

# Test Products API
Write-Host "3. Products API..." -ForegroundColor Yellow
try {
    $headers = @{"Authorization" = "Bearer $token"}
    $productsResponse = Invoke-WebRequest -Uri "$baseUrl/products" -Headers $headers -UseBasicParsing
    $productsResult = $productsResponse.Content | ConvertFrom-Json
    
    if ($productsResult.success) {
        $productCount = $productsResult.message.count
        Write-Host "   Products API working" -ForegroundColor Green
        Write-Host "   Total Products: $productCount" -ForegroundColor Cyan
    } else {
        Write-Host "   Products API failed!" -ForegroundColor Red
    }
} catch {
    Write-Host "   Products API error!" -ForegroundColor Red
}

# Test Stores API
Write-Host "4. Stores API..." -ForegroundColor Yellow
try {
    $storesResponse = Invoke-WebRequest -Uri "$baseUrl/stores" -Headers $headers -UseBasicParsing
    $storesResult = $storesResponse.Content | ConvertFrom-Json
    
    if ($storesResult.success) {
        $storeCount = $storesResult.data.Count
        Write-Host "   Stores API working" -ForegroundColor Green
        Write-Host "   Total Stores: $storeCount" -ForegroundColor Cyan
    } else {
        Write-Host "   Stores API failed!" -ForegroundColor Red
    }
} catch {
    Write-Host "   Stores API error!" -ForegroundColor Red
}

Write-Host ""
Write-Host "Backend API Test Completed!" -ForegroundColor Green
Write-Host "Ready for Flutter app testing:" -ForegroundColor Cyan
Write-Host "  Admin: admin@highlands.vn / admin123" -ForegroundColor White
Write-Host "  Customer: customer@test.com / customer123" -ForegroundColor White

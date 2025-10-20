# Highlands Coffee - Backend API Test Script
# Script này test tất cả API endpoints

Write-Host "=========================================" -ForegroundColor Green
Write-Host "Testing Highlands Coffee Backend API" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:8080/api"

# Test 1: Health Check
Write-Host "1. Testing Health Check..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing
    $healthResult = $healthResponse.Content | ConvertFrom-Json
    Write-Host "   ✓ Backend is running: $($healthResult.message)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Backend is not running: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Admin Login
Write-Host "2. Testing Admin Login..." -ForegroundColor Yellow
try {
    $loginData = @{
        email = "admin@highlands.vn"
        password = "admin123"
    } | ConvertTo-Json
    
    $loginResponse = Invoke-WebRequest -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json" -UseBasicParsing
    $loginResult = $loginResponse.Content | ConvertFrom-Json
    
    if ($loginResult.success) {
        $token = $loginResult.data.token
        $userRole = $loginResult.data.user.role
        Write-Host "   ✓ Login successful" -ForegroundColor Green
        Write-Host "   ✓ User Role: $userRole" -ForegroundColor Cyan
    } else {
        Write-Host "   ✗ Login failed: $($loginResult.error.message)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ✗ Login error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 3: Products API
Write-Host "3. Testing Products API..." -ForegroundColor Yellow
try {
    $headers = @{"Authorization" = "Bearer $token"}
    $productsResponse = Invoke-WebRequest -Uri "$baseUrl/products" -Headers $headers -UseBasicParsing
    $productsResult = $productsResponse.Content | ConvertFrom-Json
    
    if ($productsResult.success) {
        $productCount = $productsResult.message.count
        Write-Host "   ✓ Products API working" -ForegroundColor Green
        Write-Host "   ✓ Total Products: $productCount" -ForegroundColor Cyan
    } else {
        Write-Host "   ✗ Products API failed: $($productsResult.error.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "   ✗ Products API error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Stores API
Write-Host "4. Testing Stores API..." -ForegroundColor Yellow
try {
    $storesResponse = Invoke-WebRequest -Uri "$baseUrl/stores" -Headers $headers -UseBasicParsing
    $storesResult = $storesResponse.Content | ConvertFrom-Json
    
    if ($storesResult.success) {
        $storeCount = $storesResult.data.Count
        Write-Host "   ✓ Stores API working" -ForegroundColor Green
        Write-Host "   ✓ Total Stores: $storeCount" -ForegroundColor Cyan
    } else {
        Write-Host "   ✗ Stores API failed: $($storesResult.error.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "   ✗ Stores API error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Backend API Test Completed!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Ready for Flutter app testing:" -ForegroundColor Cyan
Write-Host "  Admin: admin@highlands.vn / admin123" -ForegroundColor White
Write-Host "  Customer: customer@test.com / customer123" -ForegroundColor White



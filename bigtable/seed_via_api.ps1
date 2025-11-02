# Highlands Coffee - Backend API Seeding Script
# Script này tạo dữ liệu mẫu thông qua backend API

Write-Host "Seeding database through backend API..." -ForegroundColor Green

$baseUrl = "http://localhost:8080/api"

# Function to make API calls
function Invoke-ApiCall {
    param(
        [string]$Method,
        [string]$Uri,
        [string]$Body = $null,
        [string]$ContentType = "application/json"
    )
    
    try {
        $headers = @{}
        if ($Body) {
            $response = Invoke-WebRequest -Uri $Uri -Method $Method -Body $Body -ContentType $ContentType -UseBasicParsing
        } else {
            $response = Invoke-WebRequest -Uri $Uri -Method $Method -UseBasicParsing
        }
        return $response
    } catch {
        Write-Host "Error calling $Uri : $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Test backend connection
Write-Host "Testing backend connection..." -ForegroundColor Yellow
$testResponse = Invoke-ApiCall -Method "GET" -Uri "http://localhost:8080"
if ($testResponse) {
    Write-Host "Backend is running!" -ForegroundColor Green
} else {
    Write-Host "Backend is not running. Please start it first." -ForegroundColor Red
    exit 1
}

# Register admin user
Write-Host "Creating admin user..." -ForegroundColor Yellow
$adminData = @{
    email = "admin@highlands.vn"
    password = "admin123"
    name = "Admin User"
    phone = "0900000001"
} | ConvertTo-Json

$registerResponse = Invoke-ApiCall -Method "POST" -Uri "$baseUrl/auth/register" -Body $adminData
if ($registerResponse) {
    Write-Host "Admin user created successfully!" -ForegroundColor Green
} else {
    Write-Host "Failed to create admin user" -ForegroundColor Red
}

# Register test customer
Write-Host "Creating test customer..." -ForegroundColor Yellow
$customerData = @{
    email = "customer@test.com"
    password = "customer123"
    name = "Test Customer"
    phone = "0900000000"
} | ConvertTo-Json

$customerResponse = Invoke-ApiCall -Method "POST" -Uri "$baseUrl/auth/register" -Body $customerData
if ($customerResponse) {
    Write-Host "Test customer created successfully!" -ForegroundColor Green
} else {
    Write-Host "Failed to create test customer" -ForegroundColor Red
}

Write-Host "Database seeding completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Test accounts created:" -ForegroundColor Cyan
Write-Host "  Admin: admin@highlands.vn / admin123" -ForegroundColor White
Write-Host "  Customer: customer@test.com / customer123" -ForegroundColor White
























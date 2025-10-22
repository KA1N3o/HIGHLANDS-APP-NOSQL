# Highlands Coffee - Create New Admin Script
# Script này tạo admin user mới với email khác

Write-Host "Creating new admin user..." -ForegroundColor Green

$baseUrl = "http://localhost:8080/api"

# Create new admin user
Write-Host "Creating admin user..." -ForegroundColor Yellow
$adminData = @{
    email = "admin2@highlands.vn"
    password = "admin123"
    name = "Admin User 2"
    phone = "0900000002"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-WebRequest -Uri "$baseUrl/auth/register" -Method POST -Body $adminData -ContentType "application/json" -UseBasicParsing
    $registerResult = $registerResponse.Content | ConvertFrom-Json
    
    if ($registerResult.success) {
        Write-Host "Admin user created successfully!" -ForegroundColor Green
        Write-Host "Email: admin2@highlands.vn" -ForegroundColor Cyan
        Write-Host "Password: admin123" -ForegroundColor Cyan
        Write-Host "Role: $($registerResult.data.user.role)" -ForegroundColor Cyan
    } else {
        Write-Host "Failed to create admin user: $($registerResult.error.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "Error creating admin user: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Script completed!" -ForegroundColor Green



















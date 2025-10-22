# Create test user via API

$baseUrl = "http://localhost:8080/api"

Write-Host "=== Creating Test User ===" -ForegroundColor Cyan
Write-Host ""

# Register new user
Write-Host "1. Registering new user..." -ForegroundColor Yellow
try {
    $registerData = @{
        email = "jersey@highlands.com"
        password = "jersey123"
        name = "Jersey Happon"
        phone = "0934882988"
    } | ConvertTo-Json

    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method POST -Body $registerData -ContentType "application/json"
    
    if ($registerResponse.success) {
        Write-Host "   checkmark User registered successfully" -ForegroundColor Green
        Write-Host "   User ID: $($registerResponse.data.user.id)" -ForegroundColor Gray
        Write-Host "   Email: jersey@highlands.com" -ForegroundColor Gray
        Write-Host "   Password: jersey123" -ForegroundColor Gray
    }
}
catch {
    $errorMessage = $_.Exception.Message
    if ($errorMessage -like "*already exists*") {
        Write-Host "   i User already exists, that's OK!" -ForegroundColor Yellow
    }
    else {
        Write-Host "   x Error: $errorMessage" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Login to app as admin" -ForegroundColor White
Write-Host "2. Go to User Management" -ForegroundColor White
Write-Host "3. Find 'Jersey Happon' user" -ForegroundColor White
Write-Host "4. Assign Staff role and select a store" -ForegroundColor White
Write-Host ""


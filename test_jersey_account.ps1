# Test Jersey Happon account
$baseUrl = "http://localhost:8080/api"

Write-Host "Testing Jersey Happon account..." -ForegroundColor Cyan

# Login
Write-Host "`nStep 1: Login..." -ForegroundColor Yellow
$loginBody = @{
    email = "jersey.happon@highlands.vn"
    password = "jersey123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    Write-Host "Login successful!" -ForegroundColor Green
    Write-Host "Response structure:" -ForegroundColor Cyan
    Write-Host ($loginResponse | ConvertTo-Json -Depth 5)
    
    $token = $loginResponse.data.token
    Write-Host "`nToken: $token" -ForegroundColor Green
    
    # Get user profile
    Write-Host "`nStep 2: Get user profile..." -ForegroundColor Yellow
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    $userResponse = Invoke-RestMethod -Uri "$baseUrl/users/me" -Method Get -Headers $headers
    Write-Host "User profile retrieved!" -ForegroundColor Green
    Write-Host "Response structure:" -ForegroundColor Cyan
    Write-Host ($userResponse | ConvertTo-Json -Depth 5)
    
    Write-Host "`nUser Details:" -ForegroundColor Cyan
    Write-Host "Name: $($userResponse.data.name)" -ForegroundColor White
    Write-Host "Email: $($userResponse.data.email)" -ForegroundColor White
    Write-Host "Phone: $($userResponse.data.phone)" -ForegroundColor White
    Write-Host "Role: $($userResponse.data.role)" -ForegroundColor White
    
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "Error Details: $($_.Exception.Message)" -ForegroundColor Red
}


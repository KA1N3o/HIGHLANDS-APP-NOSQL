# Highlands Coffee - Update Admin Role Script
# Script này cập nhật role của admin user thành admin

Write-Host "Updating admin user role..." -ForegroundColor Green

$baseUrl = "http://localhost:8080/api"

# Login as admin first
Write-Host "Logging in as admin..." -ForegroundColor Yellow
$loginData = @{
    email = "admin@highlands.vn"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-WebRequest -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json" -UseBasicParsing
    $loginResult = $loginResponse.Content | ConvertFrom-Json
    
    if ($loginResult.success) {
        $token = $loginResult.data.token
        $userId = $loginResult.data.user.id
        
        Write-Host "Login successful! User ID: $userId" -ForegroundColor Green
        
        # Update user role to admin
        Write-Host "Updating role to admin..." -ForegroundColor Yellow
        $updateData = @{
            role = "admin"
        } | ConvertTo-Json
        
        $headers = @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        }
        
        try {
            $updateResponse = Invoke-WebRequest -Uri "$baseUrl/admin/users/$userId/role" -Method PUT -Body '{"role":"admin"}' -Headers $headers -UseBasicParsing
            Write-Host "Role updated successfully!" -ForegroundColor Green
        } catch {
            Write-Host "Failed to update role: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "Login failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Script completed!" -ForegroundColor Green

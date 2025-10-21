# Script to update stores to be open
Write-Host "Updating stores to be open..." -ForegroundColor Green

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
    Write-Host "Login successful!" -ForegroundColor Green
    
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    # List of stores to make open
    $storesToUpdate = @(
        "store#s001",
        "store#s002", 
        "store#s003",
        "store#s004",
        "store#s005"
    )
    
    foreach ($storeId in $storesToUpdate) {
        Write-Host "Updating $storeId..." -ForegroundColor Yellow
        
        $updateData = @{
            isOpen = $true
        } | ConvertTo-Json
        
        try {
            $response = Invoke-WebRequest -Uri "$baseUrl/admin/stores/$storeId" -Method PUT -Body $updateData -ContentType "application/json" -Headers $headers
            Write-Host "Updated $storeId successfully" -ForegroundColor Green
        } catch {
            Write-Host "Failed to update $storeId : $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host "Store status update completed!" -ForegroundColor Green
} else {
    Write-Host "Failed to login as admin" -ForegroundColor Red
}









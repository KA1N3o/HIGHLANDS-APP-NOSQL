# Highlands Coffee - Fix Admin Role Script
# Script nay cap nhat role cua admin user thanh admin

Write-Host "Fixing admin user role..." -ForegroundColor Green

$baseUrl = "http://localhost:8080/api"

# Step 1: Login as admin
Write-Host ""
Write-Host "Step 1: Logging in as admin..." -ForegroundColor Yellow
$loginData = @{
    email = "admin@highlands.vn"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    
    if ($loginResponse.success) {
        $token = $loginResponse.data.token
        $userId = $loginResponse.data.user.id
        $currentRole = $loginResponse.data.user.role
        
        Write-Host "Login successful!" -ForegroundColor Green
        Write-Host "  User ID: $userId" -ForegroundColor Cyan
        Write-Host "  Current Role: $currentRole" -ForegroundColor Cyan
        
        # Step 2: Update role to admin
        Write-Host ""
        Write-Host "Step 2: Updating role to admin..." -ForegroundColor Yellow
        
        $headers = @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        }
        
        $roleData = @{
            role = "admin"
        } | ConvertTo-Json
        
        try {
            $updateResponse = Invoke-RestMethod -Uri "$baseUrl/admin/users/$userId/role" -Method PUT -Body $roleData -Headers $headers
            
            if ($updateResponse.success) {
                Write-Host "Role updated successfully!" -ForegroundColor Green
                Write-Host "  New Role: $($updateResponse.data.role)" -ForegroundColor Cyan
            } else {
                Write-Host "Failed to update role: $($updateResponse.error.message)" -ForegroundColor Red
            }
        } catch {
            Write-Host "Error updating role: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Step 3: Verify the change
        Write-Host ""
        Write-Host "Step 3: Verifying the change..." -ForegroundColor Yellow
        try {
            $verifyResponse = Invoke-RestMethod -Uri "$baseUrl/users/me" -Method GET -Headers $headers
            
            if ($verifyResponse.success) {
                $newRole = $verifyResponse.data.role
                Write-Host "Verification successful!" -ForegroundColor Green
                Write-Host "  Confirmed Role: $newRole" -ForegroundColor Cyan
                
                if ($newRole -eq "admin") {
                    Write-Host ""
                    Write-Host "SUCCESS! Admin role has been set correctly." -ForegroundColor Green
                } else {
                    Write-Host ""
                    Write-Host "WARNING: Role is still '$newRole', not 'admin'." -ForegroundColor Yellow
                }
            }
        } catch {
            Write-Host "Could not verify: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "Login failed" -ForegroundColor Red
    }
} catch {
    Write-Host "Login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Make sure backend server is running on http://localhost:8080" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Script completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green


# Test Admin Login and Role
Write-Host "Testing admin login..." -ForegroundColor Green

$baseUrl = "http://localhost:8080/api"

$loginData = @{
    email = "admin@highlands.vn"
    password = "admin123"
} | ConvertTo-Json

try {
    Write-Host "`nLogging in as admin..." -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    
    if ($response.success) {
        $user = $response.data.user
        Write-Host "`nLogin successful!" -ForegroundColor Green
        Write-Host "User ID: $($user.id)" -ForegroundColor Cyan
        Write-Host "Email: $($user.email)" -ForegroundColor Cyan
        Write-Host "Name: $($user.name)" -ForegroundColor Cyan
        Write-Host "Role: $($user.role)" -ForegroundColor Cyan
        
        if ($user.role -eq "admin") {
            Write-Host "`nSUCCESS! User has admin role." -ForegroundColor Green
        } else {
            Write-Host "`nWARNING: User role is '$($user.role)', not 'admin'." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Login failed: $($response.error.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}


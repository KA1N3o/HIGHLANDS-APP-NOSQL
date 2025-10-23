# Quick test backend promotions
$baseUrl = "http://localhost:8080/api"

Write-Host "Testing promotions API..." -ForegroundColor Cyan

# Login
$loginBody = @{ email = "admin@highlands.vn"; password = "admin123" } | ConvertTo-Json
try {
    $login = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $login.data.token
    Write-Host "Logged in successfully" -ForegroundColor Green
} catch {
    Write-Host "Login failed: $_" -ForegroundColor Red
    exit
}

# Get promotions
try {
    $headers = @{ "Authorization" = "Bearer $token" }
    $response = Invoke-RestMethod -Uri "$baseUrl/admin/promotions" -Method Get -Headers $headers
    
    if ($response.success) {
        $promos = $response.data.promotions
        Write-Host "Found $($promos.Count) promotions:" -ForegroundColor Green
        foreach ($p in $promos) {
            Write-Host "  ID: $($p.id)" -ForegroundColor White
            Write-Host "  Code: $($p.code)" -ForegroundColor Yellow
            Write-Host "  Name: $($p.name)" -ForegroundColor Cyan
            Write-Host "  Type: $($p.type), Value: $($p.value)" -ForegroundColor Gray
            Write-Host "  ---"
        }
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}


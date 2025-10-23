# Create a test promotion
$baseUrl = "http://localhost:8080/api"

Write-Host "Creating test promotion..." -ForegroundColor Cyan

# Login
$loginBody = @{ email = "admin@highlands.vn"; password = "admin123" } | ConvertTo-Json
$login = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$token = $login.data.token

# Create promotion
$promoData = @{
    code = "TESTPROMO"
    name = "Test Promotion"
    description = "Test promotion for debugging"
    type = "percentage"
    value = 10
    minOrderValue = 50000
    maxDiscount = 20000
    usageLimit = 100
    startDate = "2025-10-23T00:00:00Z"
    endDate = "2025-12-31T23:59:59Z"
    isActive = $true
} | ConvertTo-Json

try {
    $headers = @{ "Authorization" = "Bearer $token"; "Content-Type" = "application/json" }
    $response = Invoke-RestMethod -Uri "$baseUrl/admin/promotions" -Method Post -Body $promoData -Headers $headers
    
    Write-Host "Created promotion:" -ForegroundColor Green
    Write-Host ($response.data | ConvertTo-Json -Depth 3)
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message
}



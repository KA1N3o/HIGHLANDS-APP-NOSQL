# Debug promotion response
$baseUrl = "http://localhost:8080/api"

# Login
$loginBody = @{ email = "admin@highlands.vn"; password = "admin123" } | ConvertTo-Json
$login = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$token = $login.data.token

# Get promotions
$headers = @{ "Authorization" = "Bearer $token" }
$response = Invoke-RestMethod -Uri "$baseUrl/admin/promotions" -Method Get -Headers $headers

Write-Host "Raw API Response:" -ForegroundColor Cyan
Write-Host ($response | ConvertTo-Json -Depth 5)




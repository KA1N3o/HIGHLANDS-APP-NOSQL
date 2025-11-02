# Delete test promotion
$baseUrl = "http://localhost:8080/api"

Write-Host "Deleting test promotions..." -ForegroundColor Cyan

# Login
$loginBody = @{ email = "admin@highlands.vn"; password = "admin123" } | ConvertTo-Json
$login = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$token = $login.data.token

# Get all promotions
$headers = @{ "Authorization" = "Bearer $token" }
$response = Invoke-RestMethod -Uri "$baseUrl/admin/promotions" -Method Get -Headers $headers

if ($response.success) {
    $promos = $response.data
    Write-Host "Found $($promos.Count) promotions" -ForegroundColor Yellow
    
    foreach ($promo in $promos) {
        if ($promo.id) {
            Write-Host "Deleting: $($promo.code) (ID: $($promo.id))" -ForegroundColor White
            try {
                Invoke-RestMethod -Uri "$baseUrl/admin/promotions/$($promo.id)" -Method Delete -Headers $headers
                Write-Host "  Deleted successfully" -ForegroundColor Green
            } catch {
                Write-Host "  Error: $_" -ForegroundColor Red
            }
        }
    }
    Write-Host "Done!" -ForegroundColor Green
}




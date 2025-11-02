# Delete all FREES promotions
$baseUrl = "http://localhost:8080/api"

$loginBody = @{ email = "admin@highlands.vn"; password = "admin123" } | ConvertTo-Json
$login = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$token = $login.data.token

$headers = @{ "Authorization" = "Bearer $token" }
$response = Invoke-RestMethod -Uri "$baseUrl/admin/promotions" -Method Get -Headers $headers

$freesPromos = $response.data.promotions | Where-Object { $_.code -eq "FREES" }

Write-Host "Found $($freesPromos.Count) FREES promotions" -ForegroundColor Yellow

foreach ($promo in $freesPromos) {
    if ($promo.id) {
        Write-Host "Deleting: $($promo.id) - startDate: $($promo.startDate)" -ForegroundColor White
        $encodedId = [System.Uri]::EscapeDataString($promo.id)
        try {
            Invoke-RestMethod -Uri "$baseUrl/admin/promotions/$encodedId" -Method Delete -Headers $headers
            Write-Host "  Deleted!" -ForegroundColor Green
        } catch {
            Write-Host "  Error: $_" -ForegroundColor Red
        }
    }
}

Write-Host "`nAll FREES promotions deleted!" -ForegroundColor Cyan




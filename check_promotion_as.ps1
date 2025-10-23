# Check promotion AS
$baseUrl = "http://localhost:8080/api"

$loginBody = @{ email = "admin@highlands.vn"; password = "admin123" } | ConvertTo-Json
$login = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$token = $login.data.token

$headers = @{ "Authorization" = "Bearer $token" }
$response = Invoke-RestMethod -Uri "$baseUrl/admin/promotions" -Method Get -Headers $headers

$asPromo = $response.data.promotions | Where-Object { $_.code -eq "AS" }

if ($asPromo) {
    Write-Host "Promotion AS:" -ForegroundColor Cyan
    $asPromo | Format-List
} else {
    Write-Host "Promotion AS not found!" -ForegroundColor Red
}



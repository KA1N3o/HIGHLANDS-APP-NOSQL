$baseUrl = "http://localhost:8080/api"

$loginData = @{
    email = "admin@highlands.vn"
    password = "admin123"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
$token = $loginResponse.data.token

$headers = @{
    "Authorization" = "Bearer $token"
}

Write-Host "Checking all products..." -ForegroundColor Yellow
$allProducts = Invoke-RestMethod -Uri "$baseUrl/products" -Headers $headers

Write-Host "ALL Products in Database:" -ForegroundColor Cyan
Write-Host ""
foreach ($p in $allProducts.data.products) {
    $color = if ($p.category -eq "merchandise") { "Green" } else { "White" }
    Write-Host "[$($p.category)] $($p.id) - $($p.name) - $($p.price) VND" -ForegroundColor $color
}
Write-Host ""
Write-Host "Total: $($allProducts.data.count) products" -ForegroundColor Yellow

$merchProducts = $allProducts.data.products | Where-Object { $_.category -eq "merchandise" }
Write-Host "Merchandise: $($merchProducts.Count) products" -ForegroundColor Cyan


# Force delete promotion by directly calling backend with known ID
$baseUrl = "http://localhost:8080/api"
$promoId = "promo#6402078f-d6eb-4bf5-8459-44b6167cfa43"

Write-Host "Force deleting promotion: $promoId" -ForegroundColor Cyan

# Login
$loginBody = @{ email = "admin@highlands.vn"; password = "admin123" } | ConvertTo-Json
$login = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$token = $login.data.token

# Delete with full URL encoding
$headers = @{ "Authorization" = "Bearer $token" }
$encodedId = [System.Uri]::EscapeDataString($promoId)
$deleteUrl = "$baseUrl/admin/promotions/$encodedId"

Write-Host "Calling: $deleteUrl" -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri $deleteUrl -Method Delete -Headers $headers -ErrorAction Stop
    Write-Host "Success!" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json)
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Gray
    }
}

# Verify deletion
Write-Host "`nVerifying..." -ForegroundColor Cyan
Start-Sleep -Seconds 2
$verifyResponse = Invoke-RestMethod -Uri "$baseUrl/admin/promotions" -Method Get -Headers $headers
Write-Host "Remaining promotions: $($verifyResponse.data.promotions.Count)" -ForegroundColor Yellow



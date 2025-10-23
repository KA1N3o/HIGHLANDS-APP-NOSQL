# Clear all promotions from Bigtable
Write-Host "=== Clearing ALL Promotions ===" -ForegroundColor Yellow
Write-Host "This will delete all promotions from the database!" -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "Type 'YES' to confirm"
if ($confirm -ne 'YES') {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit
}

$baseUrl = "http://localhost:8080/api"

# Login
Write-Host "Logging in..." -ForegroundColor Cyan
$loginBody = @{ email = "admin@highlands.vn"; password = "admin123" } | ConvertTo-Json
try {
    $login = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $login.data.token
    Write-Host "Logged in successfully" -ForegroundColor Green
} catch {
    Write-Host "Login failed: $_" -ForegroundColor Red
    exit
}

# Get all promotions
Write-Host "Fetching promotions..." -ForegroundColor Cyan
$headers = @{ "Authorization" = "Bearer $token"; "Content-Type" = "application/json" }
$response = Invoke-RestMethod -Uri "$baseUrl/admin/promotions" -Method Get -Headers $headers

if ($response.success) {
    # Backend returns data.promotions, not data directly
    $promos = $response.data.promotions
    Write-Host "Found $($promos.Count) promotions to delete" -ForegroundColor Yellow
    
    $deleted = 0
    foreach ($promo in $promos) {
        $promoId = $promo.id
        $promoCode = $promo.code
        
        if ([string]::IsNullOrEmpty($promoId)) {
            Write-Host "Skipping promotion with empty ID (code: $promoCode)" -ForegroundColor Gray
            continue
        }
        
        Write-Host "Deleting: $promoCode (ID: $promoId)" -ForegroundColor White
        try {
            $deleteUrl = "$baseUrl/admin/promotions/$promoId"
            Invoke-RestMethod -Uri $deleteUrl -Method Delete -Headers $headers -ErrorAction Stop
            Write-Host "  Deleted!" -ForegroundColor Green
            $deleted++
        } catch {
            Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "Deleted $deleted out of $($promos.Count) promotions" -ForegroundColor Green
} else {
    Write-Host "Error fetching promotions" -ForegroundColor Red
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green


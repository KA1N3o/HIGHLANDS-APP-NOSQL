# Check all promotions in database
Write-Host ""
Write-Host "Checking all promotions in database..." -ForegroundColor Cyan

# Login
$loginUrl = "http://localhost:8080/api/auth/login"
$loginBody = @{
    email = "admin@highlands.vn"
    password = "Admin@123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri $loginUrl -Method POST -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.data.token
    Write-Host "Logged in successfully" -ForegroundColor Green
    
    # Get all promotions
    $promotionsUrl = "http://localhost:8080/api/admin/promotions"
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    $response = Invoke-RestMethod -Uri $promotionsUrl -Method GET -Headers $headers
    $promotions = $response.data.promotions
    
    Write-Host ""
    Write-Host "Total promotions: $($promotions.Count)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "=== All Promotions ===" -ForegroundColor Cyan
    
    # Group by code to find duplicates
    $groupedByCode = $promotions | Group-Object -Property code
    
    foreach ($group in $groupedByCode) {
        $code = $group.Name
        $count = $group.Count
        
        if ($count -gt 1) {
            Write-Host ""
            Write-Host "DUPLICATE CODE: $code (found $count times)" -ForegroundColor Red
            foreach ($promo in $group.Group) {
                Write-Host "   - ID: $($promo.id)" -ForegroundColor Gray
                Write-Host "     Name: $($promo.name)" -ForegroundColor Gray
                Write-Host "     Type: $($promo.type)" -ForegroundColor Gray
                Write-Host "     Active: $($promo.isActive)" -ForegroundColor Gray
                Write-Host "     Start: $($promo.startDate)" -ForegroundColor Gray
            }
        } else {
            Write-Host ""
            Write-Host "$code - $($group.Group[0].name) (ID: $($group.Group[0].id))" -ForegroundColor Green
        }
    }
    
    Write-Host ""
    Write-Host "Summary:" -ForegroundColor Cyan
    $duplicateCodes = ($groupedByCode | Where-Object { $_.Count -gt 1 }).Count
    if ($duplicateCodes -gt 0) {
        Write-Host "   Found $duplicateCodes duplicate codes!" -ForegroundColor Red
        Write-Host "   Run delete_duplicate_promotions.ps1 to remove duplicates" -ForegroundColor Yellow
    } else {
        Write-Host "   No duplicate codes found" -ForegroundColor Green
    }
    
} catch {
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

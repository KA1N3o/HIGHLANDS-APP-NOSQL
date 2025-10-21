Write-Host "Testing User Orders Performance" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# Login
$login = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body '{"email":"customer@test.com","password":"customer123"}' -ContentType "application/json"
$token = $login.data.token
$userId = $login.data.user.id

Write-Host "User ID: $userId" -ForegroundColor White
Write-Host ""

# Test getUserOrders
Write-Host "Loading user orders..." -ForegroundColor Yellow
$start = Get-Date
try {
    $orders = Invoke-RestMethod -Uri "http://localhost:8080/api/orders/user/$userId" -Headers @{"Authorization"="Bearer $token"}
    $time = [math]::Round(((Get-Date) - $start).TotalMilliseconds)
    
    Write-Host "Time: ${time}ms" -ForegroundColor $(if ($time -lt 10000) { "Green" } elseif ($time -lt 30000) { "Yellow" } else { "Red" })
    Write-Host "Orders: $($orders.data.orders.Count)" -ForegroundColor White
    
    if ($time -lt 10000) {
        Write-Host "EXCELLENT! 10x faster than before!" -ForegroundColor Green
    } elseif ($time -lt 30000) {
        Write-Host "GOOD! Much better than 101 seconds" -ForegroundColor Yellow
    } else {
        Write-Host "STILL SLOW - needs more optimization" -ForegroundColor Red
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}


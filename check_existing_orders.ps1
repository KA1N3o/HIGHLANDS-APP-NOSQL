# Check existing orders for toppings
$baseUrl = "http://localhost:8080/api"

Write-Host "=== Check Existing Orders for Toppings ===" -ForegroundColor Green
Write-Host ""

# Login
$loginData = @{
    email = "admin@highlands.vn"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod `
        -Uri "$baseUrl/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginData
    
    $token = $loginResponse.data.token
    Write-Host "Logged in!" -ForegroundColor Green
} catch {
    Write-Host "Login failed! Is backend running?" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Fetching all orders..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
}

try {
    $ordersResponse = Invoke-RestMethod `
        -Uri "$baseUrl/admin/orders" `
        -Method GET `
        -Headers $headers
    
    $orders = $ordersResponse.data.orders
    
    Write-Host "Found $($orders.Count) orders" -ForegroundColor Cyan
    Write-Host ""
    
    # Check each order for toppings
    $ordersWithToppings = 0
    
    foreach ($order in $orders | Select-Object -First 5) {
        Write-Host "Order: $($order.id)" -ForegroundColor Yellow
        Write-Host "  Status: $($order.status)" -ForegroundColor White
        Write-Host "  Total: $($order.total)" -ForegroundColor White
        
        foreach ($item in $order.items) {
            Write-Host "  Item: $($item.product.name)" -ForegroundColor Cyan
            
            if ($item.PSObject.Properties.Name -contains 'selectedToppings') {
                if ($item.selectedToppings -and $item.selectedToppings.Count -gt 0) {
                    Write-Host "    HAS TOPPINGS:" -ForegroundColor Green
                    foreach ($t in $item.selectedToppings) {
                        Write-Host "      - $($t.name): $($t.price)d" -ForegroundColor Green
                    }
                    $ordersWithToppings++
                } else {
                    Write-Host "    selectedToppings: []" -ForegroundColor Gray
                }
            } else {
                Write-Host "    selectedToppings: MISSING FIELD" -ForegroundColor Red
            }
        }
        Write-Host ""
    }
    
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Orders with toppings: $ordersWithToppings / $($orders.Count)" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Green
    
    if ($ordersWithToppings -eq 0) {
        Write-Host ""
        Write-Host "NO ORDERS HAVE TOPPINGS!" -ForegroundColor Red
        Write-Host ""
        Write-Host "This means:" -ForegroundColor Yellow
        Write-Host "  1. Backend is NOT returning selectedToppings" -ForegroundColor White
        Write-Host "  2. OR no orders were created with toppings yet" -ForegroundColor White
        Write-Host ""
        Write-Host "SOLUTION:" -ForegroundColor Cyan
        Write-Host "  1. Make sure backend was RESTARTED" -ForegroundColor White
        Write-Host "  2. Create a NEW order from the app with toppings" -ForegroundColor White
        Write-Host "  3. Run this script again" -ForegroundColor White
    } else {
        Write-Host ""
        Write-Host "Backend IS returning toppings!" -ForegroundColor Green
        Write-Host "Check if Flutter app is parsing them correctly." -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}


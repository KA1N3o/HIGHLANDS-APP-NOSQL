# Debug script to check if order has toppings
Write-Host "=== Debug Order Topping Data ===" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:8080/api"

# Login
Write-Host "Login..." -ForegroundColor Yellow
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
    Write-Host ""
} catch {
    Write-Host "Login failed!" -ForegroundColor Red
    exit 1
}

# Get orders
Write-Host "Fetching orders..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    $ordersResponse = Invoke-RestMethod `
        -Uri "$baseUrl/admin/orders?limit=10" `
        -Method GET `
        -Headers $headers
    
    $orders = $ordersResponse.data.orders
    Write-Host "Found $($orders.Count) orders" -ForegroundColor Cyan
    Write-Host ""
    
    # Show first few orders
    foreach ($order in $orders | Select-Object -First 5) {
        Write-Host "Order: $($order.id)" -ForegroundColor Cyan
        Write-Host "  User: $($order.userName)" -ForegroundColor White
        Write-Host "  Items: $($order.items.Count)" -ForegroundColor White
        
        foreach ($item in $order.items) {
            Write-Host "    - $($item.name)" -ForegroundColor Yellow
            Write-Host "      Size: $($item.size) x$($item.quantity)" -ForegroundColor Gray
            
            if ($item.selectedToppings -and $item.selectedToppings.Count -gt 0) {
                Write-Host "      TOPPINGS: $($item.selectedToppings.Count) items" -ForegroundColor Green
                foreach ($topping in $item.selectedToppings) {
                    Write-Host "        + $($topping.name) - $($topping.price)d" -ForegroundColor Green
                }
            } else {
                Write-Host "      NO TOPPINGS" -ForegroundColor Red
            }
        }
        Write-Host ""
    }
    
    # Count orders with toppings
    $ordersWithToppings = $orders | Where-Object {
        $_.items | Where-Object { $_.selectedToppings -and $_.selectedToppings.Count -gt 0 }
    }
    
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Summary:" -ForegroundColor Yellow
    Write-Host "  Total orders: $($orders.Count)" -ForegroundColor White
    Write-Host "  Orders with toppings: $($ordersWithToppings.Count)" -ForegroundColor Green
    Write-Host "  Orders without toppings: $($orders.Count - $ordersWithToppings.Count)" -ForegroundColor Red
    Write-Host ""
    
    if ($ordersWithToppings.Count -eq 0) {
        Write-Host "NO ORDERS WITH TOPPINGS FOUND!" -ForegroundColor Red
        Write-Host ""
        Write-Host "This means:" -ForegroundColor Yellow
        Write-Host "1. All orders were created BEFORE topping fix" -ForegroundColor White
        Write-Host "2. You need to create a NEW order WITH toppings" -ForegroundColor White
        Write-Host ""
        Write-Host "To test:" -ForegroundColor Cyan
        Write-Host "1. Open Flutter app" -ForegroundColor White
        Write-Host "2. Choose a coffee/tea/freeze product" -ForegroundColor White
        Write-Host "3. Select toppings" -ForegroundColor White
        Write-Host "4. Place order" -ForegroundColor White
        Write-Host "5. Check admin panel again" -ForegroundColor White
    }
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}


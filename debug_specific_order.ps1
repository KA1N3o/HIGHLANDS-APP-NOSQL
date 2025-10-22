# Debug specific order
$orderId = "ord4ed4e993"
$baseUrl = "http://localhost:8080/api"

Write-Host "=== Debug Order: $orderId ===" -ForegroundColor Green
Write-Host ""

# Login
$loginData = @{
    email = "admin@highlands.vn"
    password = "admin123"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod `
    -Uri "$baseUrl/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body $loginData

$token = $loginResponse.data.token

# Get order detail
$headers = @{
    "Authorization" = "Bearer $token"
}

$orderResponse = Invoke-RestMethod `
    -Uri "$baseUrl/orders/$orderId" `
    -Method GET `
    -Headers $headers

Write-Host "Order ID: $($orderResponse.data.id)" -ForegroundColor Cyan
Write-Host "User: $($orderResponse.data.userName)" -ForegroundColor White
Write-Host "Total: $($orderResponse.data.total)" -ForegroundColor Green
Write-Host ""

Write-Host "Items:" -ForegroundColor Yellow
foreach ($item in $orderResponse.data.items) {
    Write-Host "  Product: $($item.name)" -ForegroundColor Cyan
    Write-Host "  Size: $($item.size) x$($item.quantity)" -ForegroundColor White
    Write-Host "  Price: $($item.price)" -ForegroundColor White
    
    Write-Host "  selectedToppings field:" -ForegroundColor Yellow
    if ($item.selectedToppings) {
        Write-Host "    Type: $($item.selectedToppings.GetType().Name)" -ForegroundColor Gray
        Write-Host "    Count: $($item.selectedToppings.Count)" -ForegroundColor Gray
        
        if ($item.selectedToppings.Count -gt 0) {
            Write-Host "    TOPPINGS FOUND:" -ForegroundColor Green
            foreach ($topping in $item.selectedToppings) {
                Write-Host "      - $($topping.name): $($topping.price)d" -ForegroundColor Green
            }
        } else {
            Write-Host "    EMPTY ARRAY" -ForegroundColor Red
        }
    } else {
        Write-Host "    NULL or UNDEFINED" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "Full JSON response:" -ForegroundColor Yellow
$orderResponse.data | ConvertTo-Json -Depth 10


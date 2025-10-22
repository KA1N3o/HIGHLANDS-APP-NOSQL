# Test toppings with authentication
Write-Host "=== Test Toppings ===" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:8080/api"

# Login
Write-Host "Logging in..." -ForegroundColor Yellow
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
    Write-Host "Login successful!" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "Login failed!" -ForegroundColor Red
    exit 1
}

# Get products
Write-Host "Fetching products..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    $productsResponse = Invoke-RestMethod `
        -Uri "$baseUrl/products" `
        -Method GET `
        -Headers $headers
    
    $products = $productsResponse.data.products
    Write-Host "Found $($products.Count) products" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Check products with toppings
$productsWithToppings = $products | Where-Object { 
    $_.availableToppings -and $_.availableToppings.Count -gt 0 
}

Write-Host "Products with toppings: $($productsWithToppings.Count)" -ForegroundColor Green
Write-Host ""

if ($productsWithToppings.Count -gt 0) {
    Write-Host "Sample products:" -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($product in $productsWithToppings | Select-Object -First 3) {
        Write-Host "Product: $($product.name)" -ForegroundColor Cyan
        Write-Host "  Category: $($product.category)" -ForegroundColor White
        Write-Host "  Base price: $("{0:N0}" -f $product.price)d" -ForegroundColor White
        Write-Host "  Toppings available: $($product.availableToppings.Count)" -ForegroundColor White
        
        if ($product.availableToppings.Count -gt 0) {
            Write-Host "  Topping list:" -ForegroundColor Yellow
            foreach ($topping in $product.availableToppings | Select-Object -First 5) {
                $price = "{0:N0}" -f $topping.price
                Write-Host "    - $($topping.name): ${price}d" -ForegroundColor Green
            }
            if ($product.availableToppings.Count -gt 5) {
                Write-Host "    ... and $($product.availableToppings.Count - 5) more" -ForegroundColor Gray
            }
        }
        Write-Host ""
    }
    
    Write-Host "SUCCESS! Toppings are working!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now:" -ForegroundColor Cyan
    Write-Host "1. Open the Flutter app" -ForegroundColor White
    Write-Host "2. Select a coffee/tea/freeze product" -ForegroundColor White
    Write-Host "3. You will see the topping options" -ForegroundColor White
    Write-Host "4. Select toppings and check if price updates" -ForegroundColor White
} else {
    Write-Host "No products with toppings found!" -ForegroundColor Red
}


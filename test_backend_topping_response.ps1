# Test if backend is returning toppings in response
$baseUrl = "http://localhost:8080/api"

Write-Host "=== Test Backend Topping Response ===" -ForegroundColor Green
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
Write-Host "Creating a NEW order WITH toppings..." -ForegroundColor Yellow
Write-Host ""

# Get a product
$headers = @{
    "Authorization" = "Bearer $token"
}

$productsResponse = Invoke-RestMethod `
    -Uri "$baseUrl/products" `
    -Method GET `
    -Headers $headers

$product = $productsResponse.data.products | Where-Object { $_.category -eq 'coffee' } | Select-Object -First 1

Write-Host "Selected product: $($product.name)" -ForegroundColor Cyan
Write-Host "Available toppings: $($product.availableToppings.Count)" -ForegroundColor White

if ($product.availableToppings.Count -eq 0) {
    Write-Host "ERROR: Product has no toppings!" -ForegroundColor Red
    Write-Host "Run: .\add_toppings_with_auth.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Get store
$storesResponse = Invoke-RestMethod `
    -Uri "$baseUrl/stores" `
    -Method GET `
    -Headers $headers

$store = $storesResponse.data.stores | Select-Object -First 1

Write-Host "Selected store: $($store.name)" -ForegroundColor Cyan
Write-Host "Store ID: $($store.id)" -ForegroundColor White

# Create order with toppings
Write-Host ""
Write-Host "Creating order with 2 toppings..." -ForegroundColor Yellow

$topping1 = $product.availableToppings[0]
$topping2 = $product.availableToppings[1]

Write-Host "  Topping 1: $($topping1.name) - $($topping1.price)d" -ForegroundColor Green
Write-Host "  Topping 2: $($topping2.name) - $($topping2.price)d" -ForegroundColor Green

$orderData = @{
    storeId = $store.id
    items = @(
        @{
            productId = $product.id
            quantity = 1
            size = "Vua"
            options = @{}
            selectedToppings = @($topping1, $topping2)
        }
    )
    paymentMethod = "cash"
    deliveryMethod = "pickup"
    notes = "TEST ORDER WITH TOPPINGS"
} | ConvertTo-Json -Depth 10

Write-Host ""
Write-Host "Sending order to backend..." -ForegroundColor Yellow
Write-Host "Request body:" -ForegroundColor Gray
Write-Host $orderData -ForegroundColor DarkGray
Write-Host ""

try {
    $createResponse = Invoke-RestMethod `
        -Uri "$baseUrl/orders" `
        -Method POST `
        -Headers $headers `
        -Body $orderData `
        -ContentType "application/json"
    
    $order = $createResponse.data
    
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "ORDER CREATED!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Order ID: $($order.id)" -ForegroundColor Cyan
    Write-Host "Total: $($order.total)" -ForegroundColor White
    Write-Host ""
    Write-Host "CHECKING RESPONSE..." -ForegroundColor Yellow
    Write-Host ""
    
    $item = $order.items[0]
    Write-Host "Item details:" -ForegroundColor Cyan
    Write-Host "  Product: $($item.product.name)" -ForegroundColor White
    Write-Host "  Size: $($item.size)" -ForegroundColor White
    Write-Host "  Quantity: $($item.quantity)" -ForegroundColor White
    Write-Host ""
    
    if ($item.selectedToppings) {
        Write-Host "  selectedToppings:" -ForegroundColor Yellow
        Write-Host "    Type: $($item.selectedToppings.GetType().Name)" -ForegroundColor Gray
        Write-Host "    Count: $($item.selectedToppings.Count)" -ForegroundColor Gray
        
        if ($item.selectedToppings.Count -gt 0) {
            Write-Host ""
            Write-Host "    SUCCESS! Backend IS returning toppings:" -ForegroundColor Green
            foreach ($t in $item.selectedToppings) {
                Write-Host "      - $($t.name): $($t.price)d" -ForegroundColor Green
            }
            Write-Host ""
            Write-Host "Backend is working correctly!" -ForegroundColor Green
            Write-Host "The issue must be in Flutter app parsing." -ForegroundColor Yellow
        } else {
            Write-Host ""
            Write-Host "    ERROR! Backend returned EMPTY array" -ForegroundColor Red
            Write-Host "    Backend restart needed!" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  selectedToppings: NULL" -ForegroundColor Red
        Write-Host ""
        Write-Host "ERROR! Backend NOT returning selectedToppings!" -ForegroundColor Red
        Write-Host ""
        Write-Host "You MUST restart backend:" -ForegroundColor Yellow
        Write-Host "  1. Stop backend (Ctrl+C)" -ForegroundColor White
        Write-Host "  2. cd backend" -ForegroundColor White
        Write-Host "  3. npm start" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "Full response:" -ForegroundColor Gray
    $createResponse.data | ConvertTo-Json -Depth 10
    
} catch {
    Write-Host "ERROR creating order: $($_.Exception.Message)" -ForegroundColor Red
}


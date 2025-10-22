# Test update and fetch a single product
Write-Host "=== Test Single Product Topping ===" -ForegroundColor Green

$baseUrl = "http://localhost:8080/api"

# Login
Write-Host "Step 1: Login..." -ForegroundColor Yellow
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
Write-Host "Logged in!" -ForegroundColor Green
Write-Host ""

# Get first coffee product
Write-Host "Step 2: Get first coffee product..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
}

$productsResponse = Invoke-RestMethod `
    -Uri "$baseUrl/products" `
    -Method GET `
    -Headers $headers

$coffeeProduct = $productsResponse.data.products | Where-Object { $_.category -eq 'coffee' } | Select-Object -First 1

Write-Host "Product: $($coffeeProduct.name)" -ForegroundColor Cyan
Write-Host "ID: $($coffeeProduct.id)" -ForegroundColor White
Write-Host "Price: $($coffeeProduct.price)" -ForegroundColor White
Write-Host "Current toppings: $($coffeeProduct.availableToppings.Count)" -ForegroundColor White
Write-Host ""

# Update with toppings
Write-Host "Step 3: Update product with toppings..." -ForegroundColor Yellow

$toppings = @(
    @{
        id = "topping_test"
        name = "Test Topping"
        price = 5000
        imageUrl = ""
        isAvailable = $true
    }
)

$body = @{
    availableToppings = $toppings
} | ConvertTo-Json -Depth 10

Write-Host "Request body:" -ForegroundColor Gray
Write-Host $body -ForegroundColor Gray
Write-Host ""

$encodedProductId = [System.Web.HttpUtility]::UrlEncode($coffeeProduct.id)

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$updateResponse = Invoke-RestMethod `
    -Uri "$baseUrl/admin/products/$encodedProductId" `
    -Method PUT `
    -Headers $headers `
    -Body $body

Write-Host "Update response:" -ForegroundColor Cyan
$updateResponse.data | ConvertTo-Json -Depth 5
Write-Host ""

# Fetch again to verify
Write-Host "Step 4: Fetch product again to verify..." -ForegroundColor Yellow

Start-Sleep -Seconds 1

$verifyResponse = Invoke-RestMethod `
    -Uri "$baseUrl/products/$encodedProductId" `
    -Method GET `
    -Headers @{ "Authorization" = "Bearer $token" }

Write-Host "Fetched product:" -ForegroundColor Cyan
Write-Host "Name: $($verifyResponse.data.name)" -ForegroundColor White
Write-Host "Toppings count: $($verifyResponse.data.availableToppings.Count)" -ForegroundColor White

if ($verifyResponse.data.availableToppings -and $verifyResponse.data.availableToppings.Count -gt 0) {
    Write-Host "Toppings:" -ForegroundColor Yellow
    $verifyResponse.data.availableToppings | ForEach-Object {
        Write-Host "  - $($_.name): $($_.price)d" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "SUCCESS! Topping system is working!" -ForegroundColor Green
} else {
    Write-Host "FAILED! Toppings not saved or not returned!" -ForegroundColor Red
}


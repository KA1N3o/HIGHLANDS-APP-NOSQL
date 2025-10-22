# Add toppings to products
Write-Host "=== Add Toppings to Products ===" -ForegroundColor Green

$baseUrl = "http://localhost:8080/api"

# Define toppings
$toppings = @(
    @{
        id = "topping_hat_sen"
        name = "Hat Sen"
        price = 10000
        imageUrl = ""
        isAvailable = $true
    },
    @{
        id = "topping_cu_nang"
        name = "Cu Nang"
        price = 10000
        imageUrl = ""
        isAvailable = $true
    },
    @{
        id = "topping_thach_dao"
        name = "Thach Dao"
        price = 10000
        imageUrl = ""
        isAvailable = $true
    },
    @{
        id = "topping_thach_vai"
        name = "Thach Vai"
        price = 10000
        imageUrl = ""
        isAvailable = $true
    },
    @{
        id = "topping_thach_tra"
        name = "Thach Tra / Thach So-co-la"
        price = 10000
        imageUrl = ""
        isAvailable = $true
    },
    @{
        id = "topping_tran_chau_dua"
        name = "Tran Chau Dua"
        price = 10000
        imageUrl = ""
        isAvailable = $true
    },
    @{
        id = "topping_tran_chau_khoai_mon"
        name = "Tran Chau Khoai Mon"
        price = 10000
        imageUrl = ""
        isAvailable = $true
    },
    @{
        id = "topping_kem_whip"
        name = "Kem Whip (Kem tuoi)"
        price = 15000
        imageUrl = ""
        isAvailable = $true
    }
)

Write-Host "Toppings to add: $($toppings.Count)" -ForegroundColor Cyan
foreach ($topping in $toppings) {
    $priceFormatted = "{0:N0}" -f $topping.price
    Write-Host "  - $($topping.name): ${priceFormatted}d" -ForegroundColor White
}
Write-Host ""

# Get products
Write-Host "Fetching products..." -ForegroundColor Yellow
try {
    $products = Invoke-RestMethod -Uri "$baseUrl/products" -Method GET
    Write-Host "Found $($products.Count) products" -ForegroundColor Green
} catch {
    Write-Host "Error: Cannot fetch products" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Filter products (coffee, tea, freeze)
$eligibleCategories = @('coffee', 'tea', 'freeze')
$productsToUpdate = $products | Where-Object { $eligibleCategories -contains $_.category }

Write-Host "Products to update: $($productsToUpdate.Count) (coffee, tea, freeze)" -ForegroundColor Cyan
Write-Host ""

# Confirm
$confirmation = Read-Host "Continue? (y/n)"
if ($confirmation -ne 'y') {
    Write-Host "Cancelled!" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Updating products..." -ForegroundColor Green

$successCount = 0
$failCount = 0

foreach ($product in $productsToUpdate) {
    Write-Host "Updating: $($product.name)..." -ForegroundColor Yellow
    
    try {
        $body = @{
            availableToppings = $toppings
        } | ConvertTo-Json -Depth 10
        
        $response = Invoke-RestMethod `
            -Uri "$baseUrl/products/$($product.id)" `
            -Method PUT `
            -ContentType "application/json" `
            -Body $body
        
        Write-Host "  OK!" -ForegroundColor Green
        $successCount++
    } catch {
        Write-Host "  Failed: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
    
    Start-Sleep -Milliseconds 200
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Green
Write-Host "Success: $successCount products" -ForegroundColor Green
Write-Host "Failed: $failCount products" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })


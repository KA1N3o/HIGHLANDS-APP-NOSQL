# Script to add toppings to products with authentication
Write-Host "=== Add Toppings to Products (with Auth) ===" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:8080/api"

# Step 1: Login to get token
Write-Host "Step 1: Login to get auth token..." -ForegroundColor Yellow

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
    Write-Host "Login successful! Token obtained." -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "Login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please make sure admin account exists (email: admin@highlands.vn, password: admin123)" -ForegroundColor Yellow
    exit 1
}

# Step 2: Define toppings
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

# Step 3: Get products
Write-Host "Step 2: Fetching products..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    $productsResponse = Invoke-RestMethod `
        -Uri "$baseUrl/products" `
        -Method GET `
        -Headers $headers
    
    $products = $productsResponse.data.products
    Write-Host "Found $($products.Count) products" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "Error fetching products: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 4: Filter products
$eligibleCategories = @('coffee', 'tea', 'freeze')
$productsToUpdate = $products | Where-Object { $eligibleCategories -contains $_.category }

Write-Host "Products to update: $($productsToUpdate.Count) (coffee, tea, freeze)" -ForegroundColor Cyan
Write-Host ""

if ($productsToUpdate.Count -eq 0) {
    Write-Host "No products found to update!" -ForegroundColor Yellow
    exit 0
}

# Step 5: Confirm (auto-confirm for automation)
Write-Host "Ready to update $($productsToUpdate.Count) products..." -ForegroundColor Green
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "Step 3: Updating products..." -ForegroundColor Green
Write-Host ""

$successCount = 0
$failCount = 0

foreach ($product in $productsToUpdate) {
    Write-Host "Updating: $($product.name)..." -ForegroundColor Yellow
    
    try {
        $body = @{
            availableToppings = $toppings
        } | ConvertTo-Json -Depth 10
        
        $headers = @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        }
        
        # Encode product ID properly
        $encodedProductId = [System.Web.HttpUtility]::UrlEncode($product.id)
        
        $response = Invoke-RestMethod `
            -Uri "$baseUrl/admin/products/$encodedProductId" `
            -Method PUT `
            -Headers $headers `
            -Body $body
        
        Write-Host "  Success!" -ForegroundColor Green
        $successCount++
    } catch {
        Write-Host "  Failed: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
    
    Start-Sleep -Milliseconds 300
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Green
Write-Host "Success: $successCount products" -ForegroundColor Green
Write-Host "Failed: $failCount products" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($successCount -gt 0) {
    Write-Host "Toppings have been added to products!" -ForegroundColor Cyan
    Write-Host "You can now test the app." -ForegroundColor Cyan
}


# Test topping trong san pham
Write-Host "=== Kiem tra Topping ===" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:8080/api"

try {
    $products = Invoke-RestMethod -Uri "$baseUrl/products" -Method GET
    
    Write-Host "Tim thay $($products.Count) san pham" -ForegroundColor Cyan
    Write-Host ""
    
    $productsWithToppings = $products | Where-Object { 
        $_.availableToppings -and $_.availableToppings.Count -gt 0 
    }
    
    Write-Host "San pham co topping: $($productsWithToppings.Count)" -ForegroundColor Green
    Write-Host ""
    
    if ($productsWithToppings.Count -gt 0) {
        Write-Host "Chi tiet san pham co topping:" -ForegroundColor Yellow
        Write-Host ""
        
        foreach ($product in $productsWithToppings | Select-Object -First 5) {
            Write-Host "Product: $($product.name)" -ForegroundColor Cyan
            Write-Host "   Category: $($product.category)" -ForegroundColor White
            Write-Host "   Topping count: $($product.availableToppings.Count)" -ForegroundColor White
            
            if ($product.availableToppings.Count -gt 0) {
                Write-Host "   Available toppings:" -ForegroundColor Yellow
                foreach ($topping in $product.availableToppings) {
                    $price = "{0:N0}" -f $topping.price
                    Write-Host "     - $($topping.name): ${price}d" -ForegroundColor Green
                }
            }
            Write-Host ""
        }
        
        if ($productsWithToppings.Count -gt 5) {
            Write-Host "... va $($productsWithToppings.Count - 5) san pham khac" -ForegroundColor Gray
        }
    } else {
        Write-Host "Chua co san pham nao co topping!" -ForegroundColor Yellow
        Write-Host "Hay chay script: .\bigtable\add_toppings_to_products.ps1" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "Loi: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Hay chac chan backend dang chay o http://localhost:8080" -ForegroundColor Yellow
}

Write-Host ""

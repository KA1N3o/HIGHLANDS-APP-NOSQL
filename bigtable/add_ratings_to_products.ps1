# Add random ratings (4.3 - 4.8) to all products
Write-Host "Adding random ratings to all products..." -ForegroundColor Green

# Product IDs to update (all existing products)
$productIds = @(
    # Coffee
    'product#cf001', 'product#cf002', 'product#cf003',
    'product#esp001', 'product#esp002', 'product#esp003', 'product#esp004',
    'product#phn001', 'product#phn002', 'product#phn003', 'product#phn004', 'product#phn005',
    'product#cbd001',
    # Freeze
    'product#frz001', 'product#frz002', 'product#frz003', 'product#frz004', 'product#frz005',
    # Tea
    'product#tea001', 'product#tea002', 'product#tea003', 'product#tea004', 'product#tea005',
    'product#tea006', 'product#tea007', 'product#tea008', 'product#tea009'
)

# Create HBase commands
$commands = @()

foreach ($productId in $productIds) {
    # Generate random rating between 4.3 and 4.8
    $rating = (Get-Random -Minimum 43 -Maximum 49) / 10.0
    $rating = [math]::Round($rating, 1)
    
    # Generate random review count between 50 and 500
    $reviewCount = Get-Random -Minimum 50 -Maximum 500
    
    Write-Host "  $productId -> Rating: $rating ($reviewCount reviews)" -ForegroundColor Cyan
    
    $commands += "put 'products', '$productId', 'info:rating', '$rating'"
    $commands += "put 'products', '$productId', 'info:reviewCount', '$reviewCount'"
}

# Save to temp file
$tempFile = "add_ratings.txt"
$commands -join "`n" | Out-File -FilePath $tempFile -Encoding ASCII

Write-Host "`nExecuting HBase commands..." -ForegroundColor Yellow

# Copy to container and execute
docker cp $tempFile hbase:/tmp/
docker exec -i hbase /opt/hbase-1.2.6/bin/hbase shell /tmp/$tempFile

Write-Host "`nSuccessfully added ratings to all products!" -ForegroundColor Green
Write-Host "Ratings range from 4.3 to 4.8" -ForegroundColor Cyan

# Clean up
Remove-Item $tempFile


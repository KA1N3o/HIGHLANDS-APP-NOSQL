$ErrorActionPreference = "Continue"

Write-Host "Scanning all products from HBase..." -ForegroundColor Cyan

# Scan all products
$scanCommand = "scan 'products', {COLUMNS => ['info:name']}"
$scanResult = $scanCommand | docker exec -i hbase hbase shell -n 2>&1 | Out-String

# Extract product IDs from scan result
$productIds = @()
$scanResult -split "`n" | ForEach-Object {
    if ($_ -match '^\s*(product#[a-z0-9]+)\s+column=') {
        $productId = $Matches[1].Trim()
        if ($productIds -notcontains $productId) {
            $productIds += $productId
        }
    }
}

Write-Host "Found $($productIds.Count) products" -ForegroundColor Green
Write-Host ""

# Generate HBase commands
$commands = @()
$ratingInfo = @()

foreach ($productId in $productIds) {
    # Generate random rating between 4.3 and 4.8
    $rating = [math]::Round((Get-Random -Minimum 43 -Maximum 49) / 10, 1)
    
    # Generate random review count between 50 and 500
    $reviewCount = Get-Random -Minimum 50 -Maximum 501
    
    $ratingInfo += "  $productId -> Rating: $rating ($reviewCount reviews)"
    
    $commands += "put 'products', '$productId', 'info:rating', '$rating'"
    $commands += "put 'products', '$productId', 'info:reviewCount', '$reviewCount'"
}

Write-Host "Adding random ratings to all products..."
$ratingInfo | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
Write-Host ""

# Create temp file with commands
$tempFile = [System.IO.Path]::GetTempFileName()
$commands -join "`n" | Out-File -FilePath $tempFile -Encoding ASCII -Force

Write-Host "Executing HBase commands..." -ForegroundColor Cyan
Get-Content $tempFile | docker exec -i hbase hbase shell -n 2>&1 | Out-Null

# Cleanup
Remove-Item $tempFile -Force

Write-Host ""
Write-Host "Successfully added ratings to all $($productIds.Count) products!" -ForegroundColor Green
Write-Host "Ratings range from 4.3 to 4.8" -ForegroundColor Green


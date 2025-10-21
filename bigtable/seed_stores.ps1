# Highlands Coffee - Seed Stores Data
# Script này seed stores data vào HBase

Write-Host "Seeding stores data..." -ForegroundColor Green

# Store 1: Highlands Coffee - Nguyen Hue
Write-Host "Adding store s001..." -ForegroundColor Yellow
$store1 = @{
    id = "store#s001"
    name = "Highlands Coffee - Nguyễn Huệ"
    address = "123 Nguyễn Huệ, Q.1, TP.HCM"
    latitude = 10.7756
    longitude = 106.7019
    phone = "0901234567"
    isOpen = $true
    openTime = "07:00"
    closeTime = "22:00"
} | ConvertTo-Json

# Store 2: Highlands Coffee - Le Loi
Write-Host "Adding store s002..." -ForegroundColor Yellow
$store2 = @{
    id = "store#s002"
    name = "Highlands Coffee - Lê Lợi"
    address = "456 Lê Lợi, Q.1, TP.HCM"
    latitude = 10.7727
    longitude = 106.6988
    phone = "0901234568"
    isOpen = $true
    openTime = "07:00"
    closeTime = "23:00"
} | ConvertTo-Json

# Store 3: Highlands Coffee - Vincom Center
Write-Host "Adding store s003..." -ForegroundColor Yellow
$store3 = @{
    id = "store#s003"
    name = "Highlands Coffee - Vincom Center"
    address = "72 Lê Thánh Tôn, Q.1, TP.HCM"
    latitude = 10.7797
    longitude = 106.7011
    phone = "0901234569"
    isOpen = $true
    openTime = "08:00"
    closeTime = "22:00"
} | ConvertTo-Json

# Store 4: Highlands Coffee - Landmark 81
Write-Host "Adding store s004..." -ForegroundColor Yellow
$store4 = @{
    id = "store#s004"
    name = "Highlands Coffee - Landmark 81"
    address = "720A Điện Biên Phủ, Bình Thạnh, TP.HCM"
    latitude = 10.7943
    longitude = 106.7218
    phone = "0901234570"
    isOpen = $true
    openTime = "08:00"
    closeTime = "22:00"
} | ConvertTo-Json

# Store 5: Highlands Coffee - Crescent Mall
Write-Host "Adding store s005..." -ForegroundColor Yellow
$store5 = @{
    id = "store#s005"
    name = "Highlands Coffee - Crescent Mall"
    address = "101 Tôn Đức Thắng, Q.7, TP.HCM"
    latitude = 10.7285
    longitude = 106.7198
    phone = "0901234571"
    isOpen = $true
    openTime = "08:00"
    closeTime = "22:00"
} | ConvertTo-Json

Write-Host "Stores data prepared!" -ForegroundColor Green
Write-Host "Note: This script only prepares the data. You need to manually add these stores to your database." -ForegroundColor Cyan
Write-Host ""
Write-Host "Store 1: $($store1)" -ForegroundColor White
Write-Host "Store 2: $($store2)" -ForegroundColor White
Write-Host "Store 3: $($store3)" -ForegroundColor White
Write-Host "Store 4: $($store4)" -ForegroundColor White
Write-Host "Store 5: $($store5)" -ForegroundColor White










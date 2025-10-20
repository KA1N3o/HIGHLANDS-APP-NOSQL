# Highlands Coffee - Seed Stores to HBase
# Script này seed stores data trực tiếp vào HBase

Write-Host "Seeding stores data to HBase..." -ForegroundColor Green

# Check if HBase is running
Write-Host "Checking HBase connection..." -ForegroundColor Yellow
try {
    $hbaseCheck = docker ps | Select-String "hbase"
    if ($hbaseCheck) {
        Write-Host "HBase container is running" -ForegroundColor Green
    } else {
        Write-Host "HBase container is not running. Please start it first." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error checking HBase: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Create HBase commands file
$hbaseCommands = @"
put 'stores', 'store#s001', 'info:name', 'Highlands Coffee - Nguyễn Huệ'
put 'stores', 'store#s001', 'info:address', '123 Nguyễn Huệ, Q.1, TP.HCM'
put 'stores', 'store#s001', 'info:latitude', '10.7756'
put 'stores', 'store#s001', 'info:longitude', '106.7019'
put 'stores', 'store#s001', 'info:phone', '0901234567'
put 'stores', 'store#s001', 'info:isOpen', 'true'
put 'stores', 'store#s001', 'hours:openTime', '07:00'
put 'stores', 'store#s001', 'hours:closeTime', '22:00'
put 'stores', 'store#s002', 'info:name', 'Highlands Coffee - Lê Lợi'
put 'stores', 'store#s002', 'info:address', '456 Lê Lợi, Q.1, TP.HCM'
put 'stores', 'store#s002', 'info:latitude', '10.7727'
put 'stores', 'store#s002', 'info:longitude', '106.6988'
put 'stores', 'store#s002', 'info:phone', '0901234568'
put 'stores', 'store#s002', 'info:isOpen', 'true'
put 'stores', 'store#s002', 'hours:openTime', '07:00'
put 'stores', 'store#s002', 'hours:closeTime', '23:00'
put 'stores', 'store#s003', 'info:name', 'Highlands Coffee - Vincom Center'
put 'stores', 'store#s003', 'info:address', '72 Lê Thánh Tôn, Q.1, TP.HCM'
put 'stores', 'store#s003', 'info:latitude', '10.7797'
put 'stores', 'store#s003', 'info:longitude', '106.7011'
put 'stores', 'store#s003', 'info:phone', '0901234569'
put 'stores', 'store#s003', 'info:isOpen', 'true'
put 'stores', 'store#s003', 'hours:openTime', '08:00'
put 'stores', 'store#s003', 'hours:closeTime', '22:00'
put 'stores', 'store#s004', 'info:name', 'Highlands Coffee - Landmark 81'
put 'stores', 'store#s004', 'info:address', '720A Điện Biên Phủ, Bình Thạnh, TP.HCM'
put 'stores', 'store#s004', 'info:latitude', '10.7943'
put 'stores', 'store#s004', 'info:longitude', '106.7218'
put 'stores', 'store#s004', 'info:phone', '0901234570'
put 'stores', 'store#s004', 'info:isOpen', 'true'
put 'stores', 'store#s004', 'hours:openTime', '08:00'
put 'stores', 'store#s004', 'hours:closeTime', '22:00'
put 'stores', 'store#s005', 'info:name', 'Highlands Coffee - Crescent Mall'
put 'stores', 'store#s005', 'info:address', '101 Tôn Đức Thắng, Q.7, TP.HCM'
put 'stores', 'store#s005', 'info:latitude', '10.7285'
put 'stores', 'store#s005', 'info:longitude', '106.7198'
put 'stores', 'store#s005', 'info:phone', '0901234571'
put 'stores', 'store#s005', 'info:isOpen', 'true'
put 'stores', 'store#s005', 'hours:openTime', '08:00'
put 'stores', 'store#s005', 'hours:closeTime', '22:00'
"@

# Write commands to temporary file
$tempFile = "temp_hbase_commands.txt"
$hbaseCommands | Out-File -FilePath $tempFile -Encoding UTF8

Write-Host "Executing HBase commands..." -ForegroundColor Yellow
try {
    docker exec -i hbase-master hbase shell < $tempFile
    Write-Host "Stores data seeded successfully!" -ForegroundColor Green
    Write-Host "Total stores added: 5" -ForegroundColor Cyan
} catch {
    Write-Host "Error executing HBase commands: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Clean up temporary file
    if (Test-Path $tempFile) {
        Remove-Item $tempFile
    }
}
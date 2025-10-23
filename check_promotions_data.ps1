# Check what's actually saved in HBase promotions table
Write-Host "Checking promotions data in HBase..." -ForegroundColor Green

$scanCommand = @"
scan 'promotions', {LIMIT => 5}
exit
"@

$scanCommand | Out-File -FilePath "temp_scan.txt" -Encoding UTF8
Get-Content "temp_scan.txt" | docker exec -i hbase hbase shell

Remove-Item "temp_scan.txt" -ErrorAction SilentlyContinue


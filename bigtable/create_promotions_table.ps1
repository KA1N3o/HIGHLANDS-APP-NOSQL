# Create promotions table in HBase
Write-Host "Creating promotions table in HBase..." -ForegroundColor Green

# Create the table
$createCommand = @"
create 'promotions', 'info'
list
describe 'promotions'
exit
"@

# Write commands to temp file
$createCommand | Out-File -FilePath "temp_hbase_commands.txt" -Encoding UTF8

# Execute in HBase shell
Write-Host "Executing HBase commands..." -ForegroundColor Yellow
Get-Content "temp_hbase_commands.txt" | docker exec -i hbase hbase shell

# Clean up
Remove-Item "temp_hbase_commands.txt" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Done! Table promotions should now be created." -ForegroundColor Green
Write-Host "Now you can create promotions in your app!" -ForegroundColor Cyan


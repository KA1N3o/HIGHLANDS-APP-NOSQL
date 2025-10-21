# Test Order Status Update Bug
# This script helps test and debug the order status persistence issue

Write-Host "=== Order Status Bug Testing Script ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Steps to reproduce the bug:" -ForegroundColor Yellow
Write-Host "1. Start the backend (it will show detailed logs now)"
Write-Host "2. Login as admin in the app"
Write-Host "3. Complete an order (change status from 'ready' to 'completed')"
Write-Host "4. Watch the backend logs - you should see:"
Write-Host "   - 'Creating mutations with updateData: {status: completed}'"
Write-Host "   - 'HBase PUT command: put orders, <rowKey>, info:status, completed'"
Write-Host "   - 'Successfully executed HBase PUT commands'"
Write-Host "   - 'Parsed order status from DB: <status>'"
Write-Host "5. Logout and login again as admin"
Write-Host "6. Watch the backend logs again - you should see:"
Write-Host "   - 'getAllOrders: Row <id> raw status from parseRowData: <status>'"
Write-Host "   - 'parseOrderDataWithCache for order <id>'"
Write-Host "   - 'parseOrderDataWithCache result for <id>: status=<status>'"
Write-Host ""
Write-Host "Expected behavior: Status should be 'completed' in all logs" -ForegroundColor Green
Write-Host "Current bug: Status reverts to 'pending' after reload" -ForegroundColor Red
Write-Host ""
Write-Host "Press Enter to start the backend with debug logging..."
Read-Host

# Start the backend
cd backend
npm start


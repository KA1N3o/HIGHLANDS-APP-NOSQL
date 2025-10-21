# Verify Order Status in HBase
# This script directly queries HBase to check order status

param(
    [Parameter(Mandatory=$false)]
    [string]$OrderId
)

Write-Host "=== HBase Order Status Verification ===" -ForegroundColor Cyan
Write-Host ""

if (-not $OrderId) {
    Write-Host "Usage: .\verify_hbase_order_status.ps1 -OrderId <order_id>" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "First, let's scan all orders to find the order IDs:" -ForegroundColor Yellow
    Write-Host ""
    
    # Scan orders table
    docker exec -it hbase /opt/hbase-1.2.6/bin/hbase shell -n <<< "scan 'orders', {COLUMNS => ['info:status'], LIMIT => 10}"
} else {
    Write-Host "Looking for order: $OrderId" -ForegroundColor Yellow
    Write-Host ""
    
    # Find the full row key for this order
    Write-Host "Step 1: Finding the full row key..." -ForegroundColor Cyan
    $scanResult = docker exec -it hbase /opt/hbase-1.2.6/bin/hbase shell -n <<< "scan 'orders', {LIMIT => 100}"
    
    $rowKey = $scanResult | Select-String -Pattern "order#.*#$OrderId" | ForEach-Object { $_.Line.Trim().Split()[0] }
    
    if ($rowKey) {
        Write-Host "Found row key: $rowKey" -ForegroundColor Green
        Write-Host ""
        Write-Host "Step 2: Getting order details..." -ForegroundColor Cyan
        docker exec -it hbase /opt/hbase-1.2.6/bin/hbase shell -n <<< "get 'orders', '$rowKey'"
        Write-Host ""
        Write-Host "Step 3: Getting just the status column..." -ForegroundColor Cyan
        docker exec -it hbase /opt/hbase-1.2.6/bin/hbase shell -n <<< "get 'orders', '$rowKey', 'info:status'"
    } else {
        Write-Host "Order not found: $OrderId" -ForegroundColor Red
        Write-Host "Showing all orders:" -ForegroundColor Yellow
        docker exec -it hbase /opt/hbase-1.2.6/bin/hbase shell -n <<< "scan 'orders', {COLUMNS => ['info:status'], LIMIT => 10}"
    }
}

Write-Host ""
Write-Host "Note: The 'value=' field shows the current status in HBase" -ForegroundColor Yellow




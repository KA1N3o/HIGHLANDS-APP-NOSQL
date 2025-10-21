$baseUrl = "http://localhost:8080/api"

Write-Host "===== Merchandise Seeding Script =====" -ForegroundColor Cyan

Write-Host "1. Checking backend..." -ForegroundColor Yellow
try {
    $test = Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing -TimeoutSec 5
    Write-Host "   Backend OK" -ForegroundColor Green
} catch {
    Write-Host "   Backend NOT running" -ForegroundColor Red
    exit 1
}

Write-Host "2. Logging in..." -ForegroundColor Yellow
$loginData = '{"email":"admin@highlands.vn","password":"admin123"}'

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    $token = $loginResponse.data.token
    Write-Host "   Logged in OK" -ForegroundColor Green
} catch {
    Write-Host "   Login FAILED: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Write-Host "3. Seeding products..." -ForegroundColor Yellow
Write-Host ""

# Product 1
$p1 = '{"name":"Binh Giu Nhiet Highlands 500ml","description":"Binh giu nhiet inox cao cap","price":250000,"category":"merchandise","imageUrl":"https://images.unsplash.com/photo-1602143407151-7111542de6e8","sizes":["500ml"],"options":[],"isAvailable":true,"preparationTime":0}'
try {
    $r1 = Invoke-RestMethod -Uri "$baseUrl/admin/products" -Method POST -Headers $headers -Body $p1
    Write-Host "   OK: Binh Giu Nhiet - ID: $($r1.data.id)" -ForegroundColor Green
} catch {
    Write-Host "   FAIL: Binh Giu Nhiet - $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) { Write-Host "        $($_.ErrorDetails.Message)" -ForegroundColor Yellow }
}

# Product 2
$p2 = '{"name":"Ly Su Highlands 350ml","description":"Ly su cao cap","price":120000,"category":"merchandise","imageUrl":"https://images.unsplash.com/photo-1514228742587-6b1558fcca3d","sizes":["350ml"],"options":[],"isAvailable":true,"preparationTime":0}'
try {
    $r2 = Invoke-RestMethod -Uri "$baseUrl/admin/products" -Method POST -Headers $headers -Body $p2
    Write-Host "   OK: Ly Su - ID: $($r2.data.id)" -ForegroundColor Green
} catch {
    Write-Host "   FAIL: Ly Su - $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) { Write-Host "        $($_.ErrorDetails.Message)" -ForegroundColor Yellow }
}

# Product 3
$p3 = '{"name":"Phin Pha Ca Phe Inox","description":"Phin inox 304","price":85000,"category":"merchandise","imageUrl":"https://images.unsplash.com/photo-1610889556528-9a770e32642f","sizes":["Standard"],"options":[],"isAvailable":true,"preparationTime":0}'
try {
    $r3 = Invoke-RestMethod -Uri "$baseUrl/admin/products" -Method POST -Headers $headers -Body $p3
    Write-Host "   OK: Phin - ID: $($r3.data.id)" -ForegroundColor Green
} catch {
    Write-Host "   FAIL: Phin - $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) { Write-Host "        $($_.ErrorDetails.Message)" -ForegroundColor Yellow }
}

# Product 4
$p4 = '{"name":"Tui Tote Bag Highlands","description":"Tui canvas","price":95000,"category":"merchandise","imageUrl":"https://images.unsplash.com/photo-1590874103328-eac38a683ce7","sizes":["One Size"],"options":[{"name":"Mau sac","choices":["Trang","Be","Xanh"],"extraPrice":0}],"isAvailable":true,"preparationTime":0}'
try {
    $r4 = Invoke-RestMethod -Uri "$baseUrl/admin/products" -Method POST -Headers $headers -Body $p4
    Write-Host "   OK: Tote Bag - ID: $($r4.data.id)" -ForegroundColor Green
} catch {
    Write-Host "   FAIL: Tote Bag - $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) { Write-Host "        $($_.ErrorDetails.Message)" -ForegroundColor Yellow }
}

# Product 5
$p5 = '{"name":"Ao Thun Highlands Limited Edition","description":"Ao thun cotton","price":195000,"category":"merchandise","imageUrl":"https://images.unsplash.com/photo-1521572163474-6864f9cf17ab","sizes":["S","M","L","XL"],"options":[{"name":"Mau sac","choices":["Trang","Den","Xanh Navy"],"extraPrice":0}],"isAvailable":true,"preparationTime":0}'
try {
    $r5 = Invoke-RestMethod -Uri "$baseUrl/admin/products" -Method POST -Headers $headers -Body $p5
    Write-Host "   OK: Ao Thun - ID: $($r5.data.id)" -ForegroundColor Green
} catch {
    Write-Host "   FAIL: Ao Thun - $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) { Write-Host "        $($_.ErrorDetails.Message)" -ForegroundColor Yellow }
}

Write-Host ""
Write-Host "4. Verifying..." -ForegroundColor Yellow
try {
    $all = Invoke-RestMethod -Uri "$baseUrl/products" -Headers $headers
    $merch = $all.data.products | Where-Object { $_.category -eq "merchandise" }
    Write-Host "   Total products: $($all.data.count)" -ForegroundColor White
    Write-Host "   Merchandise: $($merch.Count)" -ForegroundColor Green
} catch {
    Write-Host "   Could not verify" -ForegroundColor Red
}

Write-Host ""
Write-Host "===== Done =====" -ForegroundColor Cyan



$baseUrl = "http://localhost:8080/api"

Write-Host "Checking backend..." -ForegroundColor Yellow
try {
    $test = Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing -TimeoutSec 5
    Write-Host "Backend is running" -ForegroundColor Green
} catch {
    Write-Host "Backend NOT running. Start it first" -ForegroundColor Red
    exit 1
}

Write-Host "Logging in..." -ForegroundColor Yellow
$loginData = @{
    email = "admin@highlands.vn"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    $token = $loginResponse.data.token
    Write-Host "Logged in" -ForegroundColor Green
} catch {
    Write-Host "Login failed" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Write-Host "Seeding products..." -ForegroundColor Yellow

$products = @(
    @{ id="product#merch001"; name="Binh Giu Nhiet Highlands 500ml"; description="Binh giu nhiet inox cao cap"; price=250000; category="merchandise"; imageUrl="https://images.unsplash.com/photo-1602143407151-7111542de6e8"; sizes=@("500ml"); options=@(); isAvailable=$true; preparationTime=0 },
    @{ id="product#merch002"; name="Ly Su Highlands 350ml"; description="Ly su cao cap voi logo Highlands"; price=120000; category="merchandise"; imageUrl="https://images.unsplash.com/photo-1514228742587-6b1558fcca3d"; sizes=@("350ml"); options=@(); isAvailable=$true; preparationTime=0 },
    @{ id="product#merch003"; name="Phin Pha Ca Phe Inox"; description="Phin inox 304 chat luong cao"; price=85000; category="merchandise"; imageUrl="https://images.unsplash.com/photo-1610889556528-9a770e32642f"; sizes=@("Standard"); options=@(); isAvailable=$true; preparationTime=0 },
    @{ id="product#merch004"; name="Tui Tote Bag Highlands"; description="Tui canvas ben dep"; price=95000; category="merchandise"; imageUrl="https://images.unsplash.com/photo-1590874103328-eac38a683ce7"; sizes=@("One Size"); options=@(@{name="Mau sac";choices=@("Trang","Be","Xanh");extraPrice=0}); isAvailable=$true; preparationTime=0 },
    @{ id="product#merch005"; name="Ao Thun Highlands Limited Edition"; description="Ao thun cotton cao cap"; price=195000; category="merchandise"; imageUrl="https://images.unsplash.com/photo-1521572163474-6864f9cf17ab"; sizes=@("S","M","L","XL"); options=@(@{name="Mau sac";choices=@("Trang","Den","Xanh Navy");extraPrice=0}); isAvailable=$true; preparationTime=0 }
)

$success = 0
foreach ($p in $products) {
    $json = $p | ConvertTo-Json -Depth 10
    try {
        Invoke-RestMethod -Uri "$baseUrl/admin/products" -Method POST -Headers $headers -Body $json | Out-Null
        Write-Host "  OK: $($p.name)" -ForegroundColor Green
        $success++
    } catch {
        Write-Host "  ERROR: $($p.name)" -ForegroundColor Red
    }
}

Write-Host "Done! Success: $success" -ForegroundColor Green



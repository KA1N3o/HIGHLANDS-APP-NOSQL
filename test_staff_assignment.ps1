# Test script to verify staff store assignment

$baseUrl = "http://localhost:8080/api"

Write-Host "=== Testing Staff Store Assignment ===" -ForegroundColor Cyan
Write-Host ""

# First, login as admin to get token
Write-Host "1. Logging in as admin..." -ForegroundColor Yellow
$loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body (@{
    email = "admin@highlands.com"
    password = "admin123"
} | ConvertTo-Json) -ContentType "application/json"

if ($loginResponse.success) {
    $token = $loginResponse.data.token
    Write-Host "   ✓ Login successful" -ForegroundColor Green
    Write-Host "   Token: $($token.Substring(0,20))..." -ForegroundColor Gray
} else {
    Write-Host "   ✗ Login failed" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Get all users to find test user
Write-Host "2. Getting all users..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$usersResponse = Invoke-RestMethod -Uri "$baseUrl/admin/users" -Method GET -Headers $headers

if ($usersResponse.success) {
    Write-Host "   ✓ Retrieved $($usersResponse.data.count) users" -ForegroundColor Green
    
    # Find Test User (Jersey)
    $testUser = $usersResponse.data.users | Where-Object { $_.email -eq "test@example.com" -or $_.name -like "*Jersey*" -or $_.name -like "*Test*" }
    
    if ($testUser) {
        Write-Host "   Found user: $($testUser.name) ($($testUser.email))" -ForegroundColor Gray
        Write-Host "   Current role: $($testUser.role)" -ForegroundColor Gray
        Write-Host "   Current assignedStoreId: $($testUser.assignedStoreId)" -ForegroundColor Gray
    } else {
        Write-Host "   ✗ Test user not found" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   ✗ Failed to get users" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Get stores
Write-Host "3. Getting stores..." -ForegroundColor Yellow
$storesResponse = Invoke-RestMethod -Uri "$baseUrl/stores" -Method GET -Headers $headers

if ($storesResponse.success -and $storesResponse.data.stores.Count -gt 0) {
    $store = $storesResponse.data.stores[0]
    Write-Host "   ✓ Retrieved $($storesResponse.data.stores.Count) stores" -ForegroundColor Green
    Write-Host "   Will assign to: $($store.name) (ID: $($store.id))" -ForegroundColor Gray
} else {
    Write-Host "   ✗ No stores found" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Update user role to staff with store assignment
Write-Host "4. Assigning staff role with store..." -ForegroundColor Yellow
try {
    $updateResponse = Invoke-RestMethod -Uri "$baseUrl/admin/users/$($testUser.id)/role" -Method PUT -Headers $headers -Body (@{
        role = "staff"
        assignedStoreId = $store.id
    } | ConvertTo-Json)

    if ($updateResponse.success) {
        Write-Host "   ✓ Successfully updated user role" -ForegroundColor Green
        Write-Host "   Role: $($updateResponse.data.role)" -ForegroundColor Gray
        Write-Host "   AssignedStoreId: $($updateResponse.data.assignedStoreId)" -ForegroundColor Gray
        
        if ($updateResponse.data.assignedStoreId -eq $store.id) {
            Write-Host "   ✓ Store assignment verified!" -ForegroundColor Green
        } else {
            Write-Host "   ✗ Store assignment mismatch!" -ForegroundColor Red
        }
    } else {
        Write-Host "   ✗ Update failed" -ForegroundColor Red
    }
} catch {
    Write-Host "   ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Cyan




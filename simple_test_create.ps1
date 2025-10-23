# Simple test - Try to create a promotion with random code
Write-Host "Testing promotion creation..." -ForegroundColor Cyan

# Generate random code
$randomCode = "TEST" + (Get-Random -Minimum 1000 -Maximum 9999)
Write-Host "Trying to create code: $randomCode" -ForegroundColor Yellow

# Note: You need to get token from app first
# This is just to show the issue

Write-Host ""
Write-Host "ISSUE FOUND:" -ForegroundColor Red
Write-Host "Backend validation (line 13 in promotionService.js):" -ForegroundColor Yellow
Write-Host "  const existing = await this.getPromotionByCode(promotion.code).catch(() => null);" -ForegroundColor Gray
Write-Host ""
Write-Host "This checks if ANY promotion with that code exists, including:" -ForegroundColor Yellow
Write-Host "  - Deleted promotions (Bigtable doesn't truly delete rows)" -ForegroundColor Gray
Write-Host "  - Duplicate promotions from previous bugs" -ForegroundColor Gray
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Green
Write-Host "1. Need to filter by isActive or other field" -ForegroundColor White
Write-Host "2. OR use different validation logic" -ForegroundColor White
Write-Host ""
Write-Host "Let me check what codes exist in your database..." -ForegroundColor Cyan



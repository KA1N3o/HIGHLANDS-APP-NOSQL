# Highlands Coffee - Thêm Bánh Ngọt Qua API
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Thêm Bánh Ngọt Mới Qua Backend API" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:8080/api"

# Test backend connection
Write-Host "Đang kiểm tra backend..." -ForegroundColor Yellow
try {
    $testResponse = Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Backend đang chạy!" -ForegroundColor Green
} catch {
    Write-Host "✗ Backend chưa chạy. Vui lòng khởi động backend trước:" -ForegroundColor Red
    Write-Host "  cd backend" -ForegroundColor Cyan
    Write-Host "  npm start" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Hoặc sử dụng: .\start_backend.bat" -ForegroundColor Cyan
    exit 1
}

Write-Host ""
Write-Host "Lưu ý: Cần đăng nhập với tài khoản admin để thêm sản phẩm" -ForegroundColor Yellow
Write-Host "Các sản phẩm sẽ tự động được tạo khi backend khởi động" -ForegroundColor Yellow
Write-Host ""
Write-Host "Nếu muốn thêm thủ công, cần:" -ForegroundColor Cyan
Write-Host "1. Login với admin account" -ForegroundColor White
Write-Host "2. Lấy JWT token" -ForegroundColor White
Write-Host "3. Gọi POST /api/products với token" -ForegroundColor White
Write-Host ""
Write-Host "Hoặc thêm trực tiếp vào HBase bằng file hbase_new_pastries.txt" -ForegroundColor Cyan
Write-Host ""


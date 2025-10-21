# Script để sửa role của admin user hiện tại hoặc tạo admin mới
# Chạy script này để có admin user với role đúng

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Highlands Coffee - Fix Admin Role" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080/api"

# Option 1: Tạo admin user mới với email admin@highlands.vn
Write-Host "Option 1: Tạo admin user mới" -ForegroundColor Yellow
Write-Host "Email: admin@highlands.vn sẽ tự động có role = admin" -ForegroundColor Cyan
Write-Host ""

$createNew = Read-Host "Bạn có muốn tạo/đăng ký lại admin@highlands.vn? (y/n)"

if ($createNew -eq "y" -or $createNew -eq "Y") {
    Write-Host ""
    Write-Host "Đăng ký admin user..." -ForegroundColor Yellow
    
    $adminData = @{
        email = "admin@highlands.vn"
        password = "admin123"
        name = "Admin User"
        phone = "0900000001"
    } | ConvertTo-Json

    try {
        $response = Invoke-WebRequest -Uri "$baseUrl/auth/register" -Method POST -Body $adminData -ContentType "application/json" -UseBasicParsing -ErrorAction Stop
        $result = $response.Content | ConvertFrom-Json
        
        if ($result.success) {
            Write-Host ""
            Write-Host "✅ Admin user đã được tạo thành công!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Thông tin đăng nhập:" -ForegroundColor Cyan
            Write-Host "  Email: admin@highlands.vn" -ForegroundColor White
            Write-Host "  Password: admin123" -ForegroundColor White
            Write-Host "  Role: $($result.data.user.role)" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Bây giờ hãy:" -ForegroundColor Green
            Write-Host "1. Logout khỏi app Flutter" -ForegroundColor White
            Write-Host "2. Login lại với:" -ForegroundColor White
            Write-Host "   Email: admin@highlands.vn" -ForegroundColor Cyan
            Write-Host "   Password: admin123" -ForegroundColor Cyan
            Write-Host "3. Menu 'Quản lý đơn hàng' sẽ xuất hiện!" -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "❌ Lỗi: $($result.error.message)" -ForegroundColor Red
            
            if ($result.error.message -like "*already exists*") {
                Write-Host ""
                Write-Host "User admin@highlands.vn đã tồn tại!" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "Có 2 cách giải quyết:" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "Cách 1: Đăng nhập với tài khoản hiện có" -ForegroundColor White
                Write-Host "  - Nếu user này đã có role = admin, chỉ cần login lại" -ForegroundColor Gray
                Write-Host ""
                Write-Host "Cách 2: Xóa user cũ và tạo lại (cần access vào HBase)" -ForegroundColor White
                Write-Host "  - Vào HBase shell" -ForegroundColor Gray
                Write-Host "  - Chạy: scan 'users'" -ForegroundColor Gray
                Write-Host "  - Tìm row key của user admin@highlands.vn" -ForegroundColor Gray
                Write-Host "  - Chạy: deleteall 'users', 'user#xxxxxx'" -ForegroundColor Gray
                Write-Host "  - Sau đó chạy lại script này" -ForegroundColor Gray
                Write-Host ""
                Write-Host "Cách 3: Update role trực tiếp (dùng admin API)" -ForegroundColor White
                Write-Host "  - Cần token của user khác để gọi admin API" -ForegroundColor Gray
            }
        }
    } catch {
        Write-Host ""
        Write-Host "❌ Lỗi kết nối: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Đảm bảo rằng:" -ForegroundColor Yellow
        Write-Host "1. Backend đang chạy (http://localhost:8080)" -ForegroundColor White
        Write-Host "2. Chạy lệnh: ./start_backend.ps1" -ForegroundColor Cyan
    }
} else {
    Write-Host ""
    Write-Host "Hủy tạo admin user mới." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "          Script hoàn tất!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ghi chú: Backend tự động set role = 'admin' cho email 'admin@highlands.vn'" -ForegroundColor Gray
Write-Host "Xem code tại: backend/src/services/authService.js (dòng 47)" -ForegroundColor Gray
Write-Host ""


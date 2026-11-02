@echo off
chcp 65001 >nul
title HairFit AI - Kết Nối Điện Thoại Android Cáp USB (Cắm Là Chạy)
echo ========================================================
echo   HAIRFIT AI - KÍCH HOẠT CẦU NỐI USB ADB REVERSE (0đ/0 PING)
echo ========================================================
echo.

set ADB_CMD=adb
if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
    set ADB_CMD="%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
)

echo Đang kiểm tra thiết bị Android cắm cáp USB...
%ADB_CMD% devices
echo.

echo Đang forward port kết nối Backend sang điện thoại...
%ADB_CMD% reverse tcp:5000 tcp:5000
%ADB_CMD% reverse tcp:3000 tcp:3000

echo.
echo ========================================================
echo  HOÀN TẤT! Điện thoại thật của bạn đã kết nối với PC:
echo  - Port 5000 (ASP.NET Core) -> http://localhost:5000
echo  - Port 3000 (Node.js API)  -> http://localhost:3000
echo.
echo  Bây giờ bạn chỉ cần mở App trên điện thoại và chạy ngay,
echo  hoàn toàn không cần sửa file .env!
echo ========================================================
echo.
pause
:: CreBy: MenBoyBMN


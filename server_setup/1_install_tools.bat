@echo off
chcp 65001 >nul
echo ========================================================
echo   HAIRFIT AI - BƯỚC 1: CÀI ĐẶT CÔNG CỤ CHO MÁY SERVER
echo ========================================================
echo.

echo [1/2] Kiểm tra .NET 8 SDK...
dotnet --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo .NET SDK chưa được cài đặt. Đang tự động cài đặt .NET 8 qua Winget...
    winget install --id Microsoft.DotNet.SDK.8 --accept-source-agreements --accept-package-agreements
) else (
    echo [OK] Đã có .NET SDK:
    dotnet --version
)
echo.

echo [2/2] Kiểm tra Cloudflare Tunnel (cloudflared)...
cloudflared --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Cloudflared chưa được cài đặt. Đang tự động cài đặt qua Winget...
    winget install --id Cloudflare.cloudflared --accept-source-agreements --accept-package-agreements
) else (
    echo [OK] Đã có Cloudflare Tunnel:
    cloudflared --version
)
echo.

echo ========================================================
echo   HOÀN TẤT CÀI ĐẶT CÔNG CỤ!
echo   Bây giờ bạn có thể chạy file "2_start_server.bat"
echo ========================================================
pause
:: CreBy: MenBoyBMN


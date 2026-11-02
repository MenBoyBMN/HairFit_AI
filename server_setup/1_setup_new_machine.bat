@echo off
chcp 65001 >nul
title HairFit AI - Setup Server Mới
echo ========================================================
echo   HAIRFIT AI - BƯỚC 1: CÀI ĐẶT SERVER MỚI (TỰ ĐỘNG)
echo ========================================================
echo.

echo [1/3] Kiểm tra .NET 8 SDK...
dotnet --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Chưa có .NET SDK. Đang tự động cài đặt qua Winget...
    winget install --id Microsoft.DotNet.SDK.8 --accept-source-agreements --accept-package-agreements
) else (
    echo [OK] Đã có .NET SDK:
    dotnet --version
)
echo.

echo [2/3] Kiểm tra Ngrok...
ngrok --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Chưa có Ngrok. Đang tự động cài đặt qua Winget...
    winget install --id Ngrok.Ngrok --accept-source-agreements --accept-package-agreements
) else (
    echo [OK] Đã có Ngrok:
    ngrok --version
)
echo.

echo [3/3] Kích hoạt Authtoken Ngrok...
set TOKEN_FILE=%~dp0ngrok_token.txt
set USER_TOKEN=

if exist "%TOKEN_FILE%" (
    for /f "usebackq eol=# tokens=*" %%t in ("%TOKEN_FILE%") do (
        if not "%%t"=="" (
            set USER_TOKEN=%%t
            goto apply_token
        )
    )
)

:apply_token
if not "%USER_TOKEN%"=="" (
    ngrok config add-authtoken %USER_TOKEN%
    echo [OK] Đã kích hoạt Authtoken từ file ngrok_token.txt thành công!
) else (
    echo [!] Chưa tìm thấy token trong ngrok_token.txt.
    echo     Nếu bạn có Ngrok Authtoken cá nhân, hãy nhập bên dưới:
    set /p INPUT_TOKEN="Nhập Authtoken (nhấn Enter để bỏ qua nếu đã cài trước đó): "
    if not "%INPUT_TOKEN%"=="" (
        ngrok config add-authtoken %INPUT_TOKEN%
        echo [OK] Đã kích hoạt Authtoken thành công!
    ) else (
        echo [BỎ QUA] Giữ nguyên thiết lập Ngrok hiện có của hệ thống.
    )
)
echo.

echo ========================================================
echo   HOÀN TẤT CÀI ĐẶT MÔI TRƯỜNG SERVER!
echo   Bây giờ bạn hãy chạy file "2_start_server_ngrok.bat"
echo ========================================================
pause
:: CreBy: MenBoyBMN


@echo off
chcp 65001 >nul
title HairFit AI - Khởi Động Node.js Server & Ngrok
echo ========================================================
echo   HAIRFIT AI - KHỞI ĐỘNG NODE.JS SERVER (PORT 3000)
echo ========================================================
echo.

echo [1/2] Đang khởi động Backend Node.js Express (Port 3000)...
start "HairFit AI Node.js Backend" cmd /k "cd /d %~dp0..\backend && npm start"

echo Đang chờ Backend khởi tạo (3s)...
timeout /t 3 /nobreak >nul
echo.

:: Tự động reverse port cho thiết bị Android cắm cáp USB (nếu có)
set ADB_CMD=adb
if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
    set ADB_CMD="%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
)
%ADB_CMD% reverse tcp:3000 tcp:3000 2>nul
%ADB_CMD% reverse tcp:5000 tcp:5000 2>nul
echo [USB Bridge] Đã kích hoạt ADB Port Forwarding cho thiết bị Android thật cắm cáp USB.
echo.

set DOMAIN=
set CONFIG_FILE=%~dp0ngrok_domain.txt

if exist "%CONFIG_FILE%" (
    for /f "usebackq eol=# tokens=*" %%i in ("%CONFIG_FILE%") do (
        if not "%%i"=="" (
            set DOMAIN=%%i
            goto found_domain
        )
    )
)

:found_domain
if not "%DOMAIN%"=="" (
    echo [2/2] Đang kết nối đường hầm Ngrok với TÊN MIỀN TĨNH CỐ ĐỊNH: %DOMAIN%
    echo Đường link API cố định cho Flutter app: https://%DOMAIN%
    echo.
    ngrok http --url=%DOMAIN% 3000
) else (
    echo [2/2] Chưa cấu hình tên miền tĩnh trong ngrok_domain.txt.
    echo Đang khởi chạy Ngrok với đường link ngẫu nhiên (Port 3000)...
    echo.
    ngrok http 3000
)

pause
:: CreBy: MenBoyBMN

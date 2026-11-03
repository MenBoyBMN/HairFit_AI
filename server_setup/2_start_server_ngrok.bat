@echo off
chcp 65001 >nul
title HairFit AI - Khoi Dong Server & Ngrok
echo ========================================================
echo   HAIRFIT AI - KHOI DONG SERVER BACKEND & NGROK TUNNEL
echo ========================================================
echo.

echo [1/3] Dang khoi dong Backend ASP.NET Core (Port 5000)...
start "HairFit AI Backend Engine" cmd /k "cd /d %~dp0..\backend\HairFit.Api && dotnet run"

echo Dang cho Backend khoi tao database va nap seed data (5s)...
timeout /t 5 /nobreak >nul
echo.

echo [2/3] Kiem tra ket noi USB Android (adb reverse)...
set ADB_CMD=adb
if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
    set ADB_CMD="%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
)
%ADB_CMD% reverse tcp:5000 tcp:5000 2>nul
echo [USB Bridge] Da san sang cho dien thoai Android cam cap USB.
echo.

echo [3/3] Dang tim kiem trinh chay Ngrok...
set NGROK_CMD=ngrok
where ngrok >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    if exist "%LOCALAPPDATA%\Microsoft\WinGet\Links\ngrok.exe" (
        set NGROK_CMD="%LOCALAPPDATA%\Microsoft\WinGet\Links\ngrok.exe"
    ) else if exist "%LOCALAPPDATA%\Microsoft\WinGet\Packages\Ngrok.Ngrok_Microsoft.Winget.Source_8wekyb3d8bbwe\ngrok.exe" (
        set NGROK_CMD="%LOCALAPPDATA%\Microsoft\WinGet\Packages\Ngrok.Ngrok_Microsoft.Winget.Source_8wekyb3d8bbwe\ngrok.exe"
    )
)

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
    echo [Tunnel Online] Ket noi Ngrok voi TEN MIEN TINH: %DOMAIN%
    echo Link API co dinh cho app tren dien thoai: https://%DOMAIN%
    echo.
    %NGROK_CMD% http --url=%DOMAIN% 5000
    if %ERRORLEVEL% NEQ 0 (
        echo Thuc hien thu lai voi flag --domain...
        %NGROK_CMD% http --domain=%DOMAIN% 5000
    )
) else (
    echo [Tunnel Online] Khoi chay Ngrok voi duong link ngau nhien...
    echo.
    %NGROK_CMD% http 5000
)

pause
:: CreBy: MenBoyBMN

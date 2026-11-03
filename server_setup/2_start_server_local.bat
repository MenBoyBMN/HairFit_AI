@echo off
chcp 65001 >nul
title HairFit AI - Khởi Động Backend ASP.NET Core (Local)
echo ========================================================
echo   HAIRFIT AI - KHỞI ĐỘNG BACKEND ASP.NET CORE (LOCAL)
echo ========================================================
echo.
echo Đang chạy Backend trên http://localhost:5000 (Port 5000)...
echo Swagger UI: http://localhost:5000/swagger
echo.
cd /d %~dp0..\backend\HairFit.Api
dotnet run
pause
:: CreBy: MenBoyBMN


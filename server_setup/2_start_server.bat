@echo off
chcp 65001 >nul
title HairFit AI Server Manager
echo ========================================================
echo   HAIRFIT AI - KHỞI ĐỘNG SERVER & CLOUDFLARE TUNNEL
echo ========================================================
echo.
echo [1/2] Đang khởi động Backend ASP.NET Core (Port 5000)...
start "HairFit AI Backend Engine" cmd /k "cd /d %~dp0..\backend\HairFit.Api && dotnet run"

echo Đang chờ Backend khởi tạo database và nạp seed data (5s)...
timeout /t 5 /nobreak >nul

echo.
echo [2/2] Đang kết nối mạng Cloudflare Tunnel toàn cầu...
echo.
echo ----------------------------------------------------------------------
echo CHÚ Ý: Tìm đường link bên dưới có đuôi: https://xxxx.trycloudflare.com
echo Copy link đó dán vào file "frontend/.env" (dòng API_BASE_URL=...)
echo ----------------------------------------------------------------------
echo.

cloudflared tunnel --url http://localhost:5000
pause
:: CreBy: MenBoyBMN


@echo off
title Cloudflare Tunnel - Sara Wena Mobile App
color 0b
echo =======================================================
echo   Starting Sara Wena Server + Cloudflare Tunnel
echo =======================================================
echo.
start "Car App Server" /min node server.js
timeout /t 2 /nobreak >nul
echo.
echo Connecting to Cloudflare Global Network...
if exist "%~dp0cloudflared.exe" (
    "%~dp0cloudflared.exe" tunnel --url http://127.0.0.1:3002
) else (
    cloudflared tunnel --url http://127.0.0.1:3002
)
pause

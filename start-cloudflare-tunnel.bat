@echo off
chcp 65001 >nul
title Cloudflare Tunnel - Sara Wena Mobile App
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-mobile-tunnel.ps1"
pause

@echo off
chcp 65001 >nul
title Cloudflare Tunnel - Sara Wena Mobile App
color 0b
node "%~dp0tunnel.js"
pause

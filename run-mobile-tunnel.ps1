# ═══════════════════════════════════════════════════════════════
# 🚗 SARA WENA — CLOUDFLARE TUNNEL MOBILE LAUNCHER
# Automatically connects to Cloudflare, extracts the HTTPS link,
# copies it to clipboard, and opens it for mobile & tablet testing.
# ═══════════════════════════════════════════════════════════════

$Host.UI.RawUI.WindowTitle = "Sara Wena Mobile Tunnel"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "       🚗 سیستەمی سارا وێنە — پەیوەستکردنی مۆبایل و تابلێت بە Cloudflare" -ForegroundColor Cyan
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Check if Node.js server is running on port 3002
$conn = Get-NetTCPConnection -LocalPort 3002 -ErrorAction SilentlyContinue
if (-not $conn) {
    Write-Host "[1/3] سێرڤەری Node.js هەڵدەکرێت لەسەر پۆڕتی 3002..." -ForegroundColor Yellow
    Start-Process node -ArgumentList "server.js" -WorkingDirectory $PSScriptRoot -WindowStyle Minimized
    Start-Sleep -Seconds 2
} else {
    Write-Host "[1/3] سێرڤەری ناوخۆیی ئامادەیە لەسەر پۆڕتی 3002." -ForegroundColor Green
}

# 2. Locate cloudflared.exe
$cfExe = if (Test-Path "$PSScriptRoot\cloudflared.exe") { "$PSScriptRoot\cloudflared.exe" } else { "cloudflared" }

$logFile = "$PSScriptRoot\cloudflare_tunnel.log"
if (Test-Path $logFile) { Remove-Item -Force $logFile -ErrorAction SilentlyContinue }

Write-Host "[2/3] پەیوەست دەبێت بە تۆڕی پارێزراوی Cloudflare..." -ForegroundColor Cyan
$p = Start-Process $cfExe -ArgumentList "tunnel --url http://127.0.0.1:3002 --logfile `"$logFile`"" -PassThru -WindowStyle Hidden

$tunnelUrl = $null
$timeout = 25
$elapsed = 0

while ($elapsed -lt $timeout) {
    Start-Sleep -Seconds 1
    $elapsed++
    if (Test-Path $logFile) {
        $content = Get-Content $logFile -Raw -ErrorAction SilentlyContinue
        if ($content -match "https://[a-zA-Z0-9.-]+\.trycloudflare\.com") {
            $tunnelUrl = $matches[0]
            break
        }
    }
}

if ($tunnelUrl) {
    try { Set-Clipboard -Value $tunnelUrl } catch {}
    Write-Host ""
    Write-Host "==========================================================================" -ForegroundColor Green
    Write-Host "  🎉 پیرۆزە! لینکی فەرمی ئەپڵیکەیشنی سارا وێنە بۆ مۆبایل و تابلێت:" -ForegroundColor Green
    Write-Host ""
    Write-Host "  👉 $tunnelUrl" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  📋 تێبینی: ئەم لینکە بە شێوەیەکی خۆکار کۆپی کرا بۆ ناو کلیپبۆرد (Clipboard)!" -ForegroundColor Cyan
    Write-Host "     دەتوانیت ڕاستەوخۆ لە ڤایبەر، واتسئاپ یان تێلێگرام بە (Ctrl + V) بینێریت بۆ مۆبایل." -ForegroundColor White
    Write-Host "==========================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "تکایە ئەم پەنجەرەیە دامەخە بۆ ئەوەی پەیوەندی مۆبایلەکان لەگەڵ داتابەیس دانەبڕێت." -ForegroundColor DarkGray

    # Open link in default browser
    Start-Process $tunnelUrl

    # Keep alive while tunnel runs
    $p.WaitForExit()
} else {
    Write-Host "⚠️ نەتوانرا لینکی تونێڵ بەدەست بهێنرێت. تکایە دڵنیابەرەوە لە هێڵی ئینتەرنێتەکەت." -ForegroundColor Red
}

/* ═══════════════════════════════════════════════════════════════
   🚗 SARA WENA — CLOUDFLARE TUNNEL MOBILE LAUNCHER
   100% Free Forever | Zero Credit Card | Zero Setup Required
   ═══════════════════════════════════════════════════════════════ */

const { spawn, exec } = require('child_process');
const http = require('http');
const path = require('path');
const fs = require('fs');

console.clear();
console.log('\x1b[36m%s\x1b[0m', '==========================================================================');
console.log('\x1b[36m%s\x1b[0m', '       🚗 سیستەمی سارا وێنە — بەستەری پارێزراو بۆ مۆبایل و تابلێت');
console.log('\x1b[36m%s\x1b[0m', '==========================================================================\n');

// 1. Check if backend server is responding on port 3002
function checkServer(cb) {
  const req = http.get('http://127.0.0.1:3002/api/setup-status', (res) => {
    cb(true);
  });
  req.on('error', () => cb(false));
  req.setTimeout(1500, () => {
    req.destroy();
    cb(false);
  });
}

function startBackendServer(callback) {
  checkServer((isRunning) => {
    if (isRunning) {
      console.log('\x1b[32m%s\x1b[0m', '✔ سێرڤەری سەرەکی کاردەکات (پۆڕتی 3002).');
      callback();
    } else {
      console.log('\x1b[33m%s\x1b[0m', '⏳ سێرڤەری سەرەکی لە پاشبنەما هەڵدەکرێت...');
      const serverProc = spawn('node', ['server.js'], {
        cwd: __dirname,
        detached: true,
        stdio: 'ignore'
      });
      serverProc.unref();

      setTimeout(() => {
        console.log('\x1b[32m%s\x1b[0m', '✔ سێرڤەری سەرەکی ئامادە کرا.');
        callback();
      }, 3000);
    }
  });
}

// 2. Start Cloudflare Tunnel
function startCloudflare() {
  const cloudflaredBin = fs.existsSync(path.join(__dirname, 'cloudflared.exe'))
    ? path.join(__dirname, 'cloudflared.exe')
    : 'cloudflared';

  console.log('\x1b[36m%s\x1b[0m', '🌐 پەیوەست دەبێت بە تۆڕی جیهانی Cloudflare (بێ بەرامبەر و بێ کارت)...');

  const cf = spawn(cloudflaredBin, ['tunnel', '--url', 'http://127.0.0.1:3002'], {
    cwd: __dirname
  });

  let urlFound = false;

  function handleData(data) {
    const text = data.toString();
    const match = text.match(/https:\/\/[a-zA-Z0-9.-]+\.trycloudflare\.com/);
    if (match && !urlFound) {
      urlFound = true;
      const url = match[0];

      // Copy to clipboard immediately
      exec(`powershell -NoProfile -Command "Set-Clipboard -Value '${url}'"`, () => {});

      // Wait 4 seconds for DNS to settle before opening browser
      setTimeout(() => {
        exec(`start ${url}`, () => {});
      }, 4000);

      console.log('\n\x1b[32m%s\x1b[0m', '==========================================================================');
      console.log('\x1b[32m%s\x1b[0m', '  🎉 پیرۆزە! بەستەری پارێزراوی ئەپڵیکەیشنی سارا وێنە بە سەرکەوتوویی ئامادەیە:');
      console.log('');
      console.log('\x1b[1m\x1b[33m%s\x1b[0m', `  👉 ${url}`);
      console.log('');
      console.log('\x1b[36m%s\x1b[0m', '  📋 تێبینی: بەستەرەکە خۆکارانە کۆپی بوو بۆ ناو کۆمپیوتەرەکەت (Clipboard).');
      console.log('\x1b[37m%s\x1b[0m', '     دەتوانیت بە (Ctrl + V) لە ڤایبەر، واتسئاپ یان تێلێگرام بینێریت بۆ مۆبایل.');
      console.log('\x1b[32m%s\x1b[0m', '==========================================================================');
      console.log('\x1b[90m%s\x1b[0m', '\nتکایە ئەم پەنجەرەیە بە کراوەیی بهێڵەرەوە تا پەیوەندی مۆبایلەکان دانەبڕێت...');
    }
  }

  cf.stdout.on('data', handleData);
  cf.stderr.on('data', handleData);

  cf.on('close', (code) => {
    console.log(`\nCloudflare tunnel closed (Code: ${code})`);
  });

  cf.on('error', (err) => {
    console.error('\n\x1b[31m%s\x1b[0m', 'هەڵە لە دەستپێکردنی Cloudflare: ' + err.message);
  });
}

// Run
startBackendServer(() => {
  startCloudflare();
});

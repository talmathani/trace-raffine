# SECURE BUILD SCRIPT
$ErrorActionPreference = "Stop"

Write-Host "=== SECURE BUILD START ===" -ForegroundColor Cyan

# 1. تنظيف
flutter clean

# 2. تحليل
flutter analyze
if ($LASTEXITCODE -ne 0) {
    Write-Host "ANALYSIS FAILED" -ForegroundColor Red
    exit 1
}

# 3. اختبارات
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "TESTS FAILED" -ForegroundColor Red
    exit 1
}

# 4. بناء محصّن مع Obfuscation
flutter build web --release `
  --dart-define=SECURE_MODE=true `
  --obfuscate `
  --split-debug-info=build/debug-info

Write-Host "=== SECURE BUILD COMPLETE ===" -ForegroundColor Green

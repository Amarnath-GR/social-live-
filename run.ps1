$backendPath = Join-Path $PSScriptRoot "..\social-live-mvp"

Write-Host "Checking if backend is running..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/v1" -TimeoutSec 2 -ErrorAction Stop
    Write-Host "Backend already running!" -ForegroundColor Green
} catch {
    Write-Host "Starting backend server..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$backendPath'; npm run start:dev"
    Write-Host "Waiting for backend to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 8
}

Write-Host "Starting Flutter app..." -ForegroundColor Cyan
flutter run

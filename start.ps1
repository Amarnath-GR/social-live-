Write-Host "Starting Social Live Backend and Flutter App..." -ForegroundColor Cyan
Write-Host ""

# Start backend in new window
Write-Host "[1/2] Starting NestJS Backend..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '..\social-live-mvp'; npm run start:dev"

# Wait for backend
Write-Host "[2/2] Waiting for backend to start (5 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Start Flutter
Write-Host "Starting Flutter App..." -ForegroundColor Green
flutter run

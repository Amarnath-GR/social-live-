@echo off
echo Fixing Backend TypeScript Errors...

cd /d "c:\Users\Amarnath.G.Rathod\social-live-flutter-mvp\social-live-mvp"

echo 1. Installing missing dependencies...
npm install @nestjs/mongoose mongoose --legacy-peer-deps

echo 2. Fixing Prisma client generation...
rmdir /s /q node_modules\.prisma 2>nul
npx prisma generate --force

echo 3. Fixing import statements...
powershell -Command "(Get-ChildItem -Path 'test' -Filter '*.ts' -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'import \* as request from ''supertest'';', 'import request from ''supertest'';' | Set-Content $_.FullName }"

echo 4. Fixing test files...
powershell -Command "(Get-ChildItem -Path 'test' -Filter '*.e2e-spec.ts' -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'request\(app\.getHttpServer\(\)\)', 'request.default(app.getHttpServer())' | Set-Content $_.FullName }"

echo 5. Building project to check for remaining errors...
npm run build

echo Backend fix completed!
pause
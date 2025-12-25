@echo off
echo 🌐 Starting Social Live Web Portal

cd social-live-web

REM Install dependencies if needed
if not exist node_modules (
    echo 📦 Installing dependencies...
    npm install
)

REM Start development server
echo 🚀 Starting Next.js development server...
npm run dev

pause
#!/usr/bin/env node

const { spawn, exec } = require('child_process');
const http = require('http');

console.log('🚀 Starting Social Live Flutter App...');

// Check if backend is running
function checkBackend() {
    return new Promise((resolve) => {
        const req = http.get('http://localhost:3000/health', (res) => {
            resolve(true);
        });
        req.on('error', () => resolve(false));
        req.setTimeout(2000, () => {
            req.destroy();
            resolve(false);
        });
    });
}

// Start backend server
function startBackend() {
    return new Promise((resolve) => {
        console.log('📡 Starting backend server...');
        const backend = spawn('npm', ['run', 'start:dev'], {
            cwd: './social-live-mvp',
            shell: true,
            detached: true
        });
        
        // Wait for backend to be ready
        const checkInterval = setInterval(async () => {
            if (await checkBackend()) {
                clearInterval(checkInterval);
                console.log('✅ Backend is ready!');
                resolve();
            }
        }, 2000);
    });
}

// Start Flutter app
function startFlutter() {
    console.log('📱 Starting Flutter app...');
    const flutter = spawn('flutter', ['run'], {
        cwd: './social-live-flutter',
        shell: true,
        stdio: 'inherit'
    });
    
    flutter.on('close', (code) => {
        console.log(`Flutter app exited with code ${code}`);
        process.exit(code);
    });
}

// Main execution
async function main() {
    const isBackendRunning = await checkBackend();
    
    if (isBackendRunning) {
        console.log('✅ Backend is already running!');
    } else {
        await startBackend();
    }
    
    startFlutter();
}

main().catch(console.error);
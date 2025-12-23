# Physical Device Setup Guide

## Quick Setup (3 Steps)

### 1. Start Backend
```bash
# Run this first
./start-backend-physical.bat
```

### 2. Setup Device Connection
```bash
# Run this to configure firewall and network
./setup-physical-device.bat
```

### 3. Start Flutter App
```bash
# Connect your phone via USB and run
./start-flutter-physical.bat
```

## Manual Setup

### Backend Setup
1. **Start Backend Server**:
   ```bash
   cd social-live-mvp
   npm install
   npm start
   ```

2. **Verify Backend Running**:
   - Open browser: `http://192.168.1.6:2307/api/v1/health`
   - Should return: `{"status": "ok"}`

### Network Configuration
1. **Add Firewall Rule**:
   ```bash
   netsh advfirewall firewall add rule name="Flutter Backend 2307" dir=in action=allow protocol=TCP localport=2307
   ```

2. **Check IP Address**:
   ```bash
   ipconfig | findstr "IPv4"
   ```
   - Current IP: `192.168.1.6`

### Flutter App Setup
1. **Connect Physical Device**:
   - Enable USB Debugging on Android
   - Connect via USB cable
   - Verify: `flutter devices`

2. **Update API Configuration**:
   - File: `lib/config/api_config.dart`
   - Main URL: `http://192.168.1.6:2307`
   - Fallback URLs configured

3. **Run App**:
   ```bash
   cd social-live-flutter
   flutter run --release
   ```

## Troubleshooting

### Backend Connection Failed
1. **Check Backend Status**:
   - Browser: `http://192.168.1.6:2307/api/v1/health`
   - Should return JSON response

2. **Check Firewall**:
   - Windows Firewall should allow port 2307
   - Run: `./add-firewall-rule.bat`

3. **Check Network**:
   - Phone and PC on same WiFi
   - Phone can ping: `192.168.1.6`

### App Connection Issues
1. **Use Connection Test Screen**:
   - Built-in connection tester
   - Tests all fallback URLs
   - Shows detailed error messages

2. **Check API Endpoints**:
   - All endpoints use: `http://192.168.1.6:2307/api/v1/`
   - Fallback to localhost if needed

### Common Issues
1. **Port 2307 blocked**: Run firewall script
2. **Wrong IP address**: Update `api_config.dart`
3. **Backend not running**: Start with `npm start`
4. **Different WiFi networks**: Connect to same network

## Network Requirements
- **Same WiFi Network**: Phone and PC must be connected to same WiFi
- **Port 2307 Open**: Windows Firewall must allow port 2307
- **IP Address**: Currently configured for `192.168.1.6`

## Files Created
- `setup-physical-device.bat` - Complete setup script
- `start-backend-physical.bat` - Backend startup
- `start-flutter-physical.bat` - Flutter app startup
- `connection_test_screen.dart` - Connection debugging tool

## Success Indicators
✅ Backend responds at: `http://192.168.1.6:2307/api/v1/health`
✅ Firewall rule added for port 2307
✅ Flutter app connects without "backend connection failed"
✅ All API calls work (login, profile, transactions, etc.)
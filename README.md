# Social Live MVP - Flutter Frontend

Flutter mobile application for the Social Live MVP platform.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.9.2+
- Node.js and npm (for backend)
- NestJS backend in `../social-live-mvp`

### Easy Start (Recommended)

**Windows:**
```bash
# Double-click or run:
start.bat

# Or using PowerShell:
.\start.ps1
```

This automatically starts both backend and Flutter app!

### Manual Setup

1. **Start the Backend First**
   ```bash
   cd ../social-live-mvp
   npm run start:dev
   ```
   Backend will run at: `http://localhost:3000/api/v1`

2. **Install Flutter Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the Flutter App**
   ```bash
   flutter run
   ```

## 📱 Platform Support

The app automatically detects the platform and uses appropriate backend URLs:

- **Desktop/iOS Simulator**: `http://localhost:3000/api/v1`
- **Android Emulator**: `http://10.0.2.2:3000/api/v1`

## 🔧 Features

- ✅ Platform-aware API configuration
- ✅ Backend connectivity testing
- ✅ Error handling for network issues
- ✅ Crash prevention with try-catch blocks
- ✅ Connection status display
- ✅ Demo account information

## 👥 Demo Accounts

- **Admin**: admin@demo.com / Demo123!
- **User**: john@demo.com / Demo123!

## 🛠 Project Structure

```
lib/
├── config/
│   └── api_config.dart          # Platform-aware API URLs
├── services/
│   ├── api_client.dart          # HTTP client with error handling
│   └── auth_service.dart        # Authentication service
└── main.dart                    # Main app with connectivity testing
```

## 🔍 Troubleshooting

1. **"Cannot connect to server"**
   - Ensure backend is running: `npm run start:dev`
   - Check if port 3000 is available

2. **Android emulator connection issues**
   - App automatically uses `10.0.2.2:3000`
   - Ensure emulator can reach host machine

3. **App crashes on mobile**
   - All API calls are wrapped in try-catch blocks
   - Error messages are displayed instead of crashes

## 📦 Dependencies

- `dio`: HTTP client for API calls
- `shared_preferences`: Local storage for tokens
- `flutter/material`: UI framework

## 🚀 Next Steps

1. Test backend connection using the "Test Backend Connection" button
2. Once connected, implement login screen
3. Add social feed, wallet, and streaming features
4. Integrate real-time chat functionality

---

**Backend Repository**: `../social-live-mvp`
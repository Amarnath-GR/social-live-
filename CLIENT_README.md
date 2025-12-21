# Social Live - Mobile App

The mobile application for Social Live platform.

## What This Is

A mobile app that lets users:
- Create and share posts
- Like and comment on content
- Use virtual coins in their wallet
- Watch and create live streams
- Chat with other users in real-time

## What You Need

Before you can run the app, install:
- **Flutter** - [Installation guide](https://flutter.dev/docs/get-started/install)
- **Android Studio** or **Xcode** (for running on devices)
- **Git** - [Download here](https://git-scm.com/)

## Quick Start (3 minutes)

### 1. Get the Code
```bash
git clone <your-repository-url>
cd social-live-flutter
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Start the App
```bash
flutter run
```

The app will open on your connected device or emulator.

## Demo Login

Use these accounts to test the app:

**Admin User**
- Email: `admin@demo.com`
- Password: `Demo123!`

**Regular User**
- Email: `john@demo.com`
- Password: `Demo123!`

*Note: The backend server must be running first!*

## Server Connection

The app connects to the backend server at:
- **Android Emulator**: `http://10.0.2.2:3000/api/v1`
- **iOS Simulator**: `http://localhost:3000/api/v1`
- **Real Device**: Update IP address in `lib/config/api_config.dart`

## Running on Different Devices

### Android Emulator
1. Open Android Studio
2. Start an emulator
3. Run `flutter run`

### iOS Simulator (Mac only)
1. Open Xcode
2. Start iOS Simulator
3. Run `flutter run`

### Real Device
1. Enable developer mode on your phone
2. Connect via USB
3. Run `flutter run`
4. Update server IP in `lib/config/api_config.dart`

## App Features

### Login Screen
- Enter email and password
- Quick demo account buttons
- Skip login option for testing

### Home Screen
- View social posts
- Create new posts
- Like and comment
- Navigate to other features

### Wallet
- Check coin balance
- View transaction history
- Spend coins on features

## Configuration

To change server settings, edit `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
}
```

Change the IP address to match your server location.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run on specific device
flutter run -d <device-id>

# See available devices
flutter devices

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Troubleshooting

**App won't start?**
1. Check Flutter installation: `flutter doctor`
2. Install dependencies: `flutter pub get`
3. Make sure a device/emulator is running: `flutter devices`

**Can't connect to server?**
1. Make sure backend server is running
2. Check the IP address in `api_config.dart`
3. For Android emulator, use `10.0.2.2`
4. For iOS simulator, use `localhost`

**Login not working?**
1. Make sure backend server has demo data: `npm run seed:demo`
2. Use the demo accounts shown on login screen
3. Check server logs for errors

**App crashes?**
1. Run `flutter clean`
2. Run `flutter pub get`
3. Run `flutter run` again

## Development Mode

For development, you can:
- Hot reload: Press `r` in terminal
- Hot restart: Press `R` in terminal
- Quit: Press `q` in terminal

## What You'll See

When the app starts:
- Splash screen with server connection check
- Login screen with demo account options
- Home screen with social features
- Navigation to wallet, streaming, and chat

## Support

If you need help:
1. Check Flutter installation: `flutter doctor`
2. Make sure backend server is running
3. Check this README for common issues
4. Contact the development team

---

**Status**: Ready for demo and testing
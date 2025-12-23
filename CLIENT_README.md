# Social Live MVP - Complete Platform

A social media platform with live streaming and virtual wallet features.

## What's Included

This project contains:
- **Backend Server** - Handles all app functionality
- **Mobile App** - Flutter app for iOS and Android
- **Demo Data** - Ready-to-use test accounts

## Quick Demo Setup (10 minutes)

### Step 1: Start the Backend Server
```bash
cd social-live-mvp
npm install
npm run start:demo
```

### Step 2: Start the Mobile App
```bash
cd social-live-flutter
flutter pub get
flutter run
```

### Step 3: Login and Test
Use these demo accounts:
- **Admin**: `admin@demo.com` / `Demo123!`
- **User**: `john@demo.com` / `Demo123!`

## What You Need

**For Backend:**
- Node.js 18+ ([Download](https://nodejs.org/))

**For Mobile App:**
- Flutter SDK ([Install Guide](https://flutter.dev/docs/get-started/install))
- Android Studio or Xcode

## Project Structure

```
social-live-flutter-mvp/
├── social-live-mvp/          # Backend server
│   ├── CLIENT_README.md      # Backend setup guide
│   └── start-demo.bat        # Quick demo start
├── social-live-flutter/      # Mobile app
│   ├── CLIENT_README.md      # App setup guide
│   └── lib/                  # App source code
└── DEMO_INSTRUCTIONS.md      # Full demo guide
```

## Features

### Social Media
- User posts and comments
- Like system
- Real-time social feed
- User profiles

### Virtual Wallet
- Coin-based economy
- Transaction history
- Secure payments
- Admin controls

### Live Streaming
- Create live streams
- Watch active streams
- Stream management
- AWS integration

### Real-time Chat
- Instant messaging
- WebSocket connections
- Multi-user support

### Admin Panel
- User management
- Content moderation
- Wallet operations
- Platform statistics

## Demo Flow

1. **Setup** (5 min) - Install and start both servers
2. **Login** (1 min) - Use demo accounts
3. **Social Features** (5 min) - Create posts, like, comment
4. **Wallet** (3 min) - Check balance, make transactions
5. **Streaming** (3 min) - Create and manage streams
6. **Admin** (3 min) - User management, moderation

## Getting Help

**Backend Issues:**
- See `social-live-mvp/CLIENT_README.md`
- Run `node verify-setup.js`

**Mobile App Issues:**
- See `social-live-flutter/CLIENT_README.md`
- Run `flutter doctor`

**Demo Issues:**
- See `DEMO_INSTRUCTIONS.md`
- Reset demo data: `npm run seed:demo`

## Technical Details

**Backend:**
- Node.js with NestJS framework
- PostgreSQL database with Prisma
- JWT authentication
- AWS cloud integration
- WebSocket real-time features

**Mobile App:**
- Flutter framework
- Cross-platform (iOS/Android)
- Material Design UI
- Secure API integration

**Security:**
- Rate limiting
- Input validation
- Encrypted passwords
- Secure tokens
- CORS protection

## Production Ready

This MVP includes:
- ✅ Complete feature set
- ✅ Security measures
- ✅ Database migrations
- ✅ Deployment scripts
- ✅ Documentation
- ✅ Demo data
- ✅ Error handling

## Next Steps

After demo:
1. **Production Setup** - Deploy to cloud servers
2. **Custom Branding** - Update colors, logos, text
3. **Feature Expansion** - Add e-commerce, advanced social features
4. **Mobile Store** - Publish to App Store and Google Play
5. **Scaling** - Add load balancing, CDN, monitoring

---

**Status**: Ready for demo, testing, and production deployment
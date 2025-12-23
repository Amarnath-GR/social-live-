# Client Demo Instructions

## 🎯 Demo Overview
Social Live MVP - Complete backend with Flutter frontend demonstration.

## 🚀 Quick Demo Start

### Backend Setup (5 minutes)
```bash
cd social-live-mvp
./start-demo.bat    # Windows
# or
./start-demo.sh     # Linux/Mac
```

### Flutter App Setup (2 minutes)
```bash
cd social-live-flutter
flutter run
```

## 👤 Demo Accounts

### Admin Account
- **Email**: `admin@demo.com`
- **Password**: `Demo123!`
- **Features**: Full admin access, wallet management, user moderation

### Regular Users
- **Email**: `john@demo.com` / **Password**: `Demo123!`
- **Email**: `jane@demo.com` / **Password**: `Demo123!`
- **Features**: Post creation, wallet usage, live streaming

## 🎬 Demo Flow

### 1. Authentication (2 minutes)
- Open Flutter app
- Login with `john@demo.com` / `Demo123!`
- Show token-based authentication
- Navigate to home screen

### 2. Social Features (5 minutes)
- Create a new post
- Like/unlike posts
- Add comments
- View paginated feed

### 3. Wallet System (3 minutes)
- Check wallet balance (100 coins)
- Perform coin transaction
- View transaction history
- Show atomic operations

### 4. Live Streaming (3 minutes)
- Create stream channel
- Start/stop stream
- View active streams
- Show AWS IVS integration

### 5. Admin Features (3 minutes)
- Login as admin (`admin@demo.com`)
- View user management
- Add/remove coins
- Moderate content

### 6. Real-time Chat (2 minutes)
- Open multiple browser tabs
- Send messages between users
- Show WebSocket connectivity

## 🔧 Technical Highlights

### Backend Architecture
- **NestJS** with TypeScript
- **Prisma ORM** with PostgreSQL
- **JWT Authentication** with refresh tokens
- **AWS Integration** (IVS + S3)
- **WebSocket** real-time features

### Security Features
- Rate limiting (100 req/min)
- Input validation
- Security headers
- Role-based access control
- Password hashing

### Database Design
- Optimized schema with proper indexing
- Atomic transactions for wallet operations
- Migration system for schema updates

## 📱 Mobile Features
- Cross-platform Flutter app
- Native performance
- Secure API integration
- Token management
- Error handling

## 🎯 Demo Success Metrics
- ✅ Stable startup (< 30 seconds)
- ✅ All demo accounts working
- ✅ API responses < 200ms
- ✅ Real-time features operational
- ✅ No debug logs in demo mode

## 🚨 Troubleshooting

### Backend Issues
```bash
# Reset demo data
npm run seed:reset
npm run seed:demo

# Verify setup
node verify-setup.js
```

### Flutter Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## 📊 Performance Expectations
- **Startup Time**: < 30 seconds
- **API Response**: < 200ms average
- **Database Queries**: Optimized with indexing
- **Concurrent Users**: Tested up to 100
- **Memory Usage**: Stable under demo load

## 🎉 Demo Conclusion Points
1. **Complete MVP** - All core features implemented
2. **Production Ready** - Scalable architecture
3. **Security First** - Enterprise-grade security
4. **Real-time Capable** - WebSocket integration
5. **Cloud Native** - AWS services integration
6. **Mobile Ready** - Flutter cross-platform app

---

**Demo Duration**: ~20 minutes  
**Setup Time**: ~7 minutes  
**Total Time**: ~30 minutes
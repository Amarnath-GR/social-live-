# User Profile System

This document describes the complete user profile system implementation for the Social Live Flutter MVP.

## Overview

The profile system provides comprehensive user profile management including:
- Profile viewing and editing
- Avatar upload
- Account settings
- Password management
- Account verification status
- User statistics
- Account deletion

## Architecture

### Frontend (Flutter)

#### Models
- `User` - Main user data model with all profile information
- `UserStats` - User engagement statistics (posts, likes, comments)
- `UpdateProfileRequest` - DTO for profile update requests

#### Services
- `ProfileService` - Handles all profile-related API calls
- `AuthService` - Authentication and session management

#### Screens
- `ProfileScreen` - Main profile display with stats and navigation
- `ProfileEditScreen` - Profile editing with avatar upload
- `ProfileSettingsScreen` - Account settings and security options

#### Widgets
- `UserProfileWidget` - Reusable user profile display component
- `UserAvatarWidget` - Reusable avatar display component

### Backend (NestJS)

#### Controllers
- `UsersController` - Profile management endpoints

#### Services
- `UsersService` - Profile business logic and database operations

#### DTOs
- `UpdateProfileDto` - Profile update validation
- `ChangePasswordDto` - Password change validation
- `UpdateUserStatusDto` - Admin user status management

## Features

### 1. Profile Display
- User avatar with fallback to initials
- Name and username display
- Verification badges (KYC, KYB, AML)
- User statistics (posts, likes, comments)
- Wallet balance integration
- Account creation date

### 2. Profile Editing
- Name and username editing with validation
- Avatar upload with image picker
- Real-time validation feedback
- Optimistic UI updates

### 3. Avatar Management
- Camera and gallery image selection
- Image compression and optimization
- Avatar removal option
- Fallback to user initials

### 4. Account Settings
- Password change with current password verification
- Notification preferences
- Privacy settings
- Security options
- Account deletion

### 5. Verification Status
- KYC verification display
- KYB verification display
- AML verification display
- Verification management navigation

## API Endpoints

### Profile Management
```
GET /users/me - Get current user profile
PUT /users/me - Update user profile
POST /users/avatar - Upload user avatar
PUT /users/change-password - Change password
DELETE /users/me - Delete account
GET /users/:id - Get user by ID (public profiles)
```

### Response Format
All endpoints return standardized responses:
```json
{
  "success": true,
  "data": { ... },
  "message": "Optional message"
}
```

## Security Features

### 1. Authentication
- JWT token-based authentication
- Automatic token refresh
- Secure token storage

### 2. Authorization
- User can only edit their own profile
- Admin-only endpoints for user management
- Role-based access control

### 3. Validation
- Input sanitization and validation
- Username uniqueness checking
- Password strength requirements
- File upload restrictions

### 4. Privacy
- Secure password hashing with bcrypt
- Optional profile visibility settings
- Data anonymization on account deletion

## User Experience

### 1. Navigation Flow
```
Home → Profile Tab → Profile Screen
                  ├── Edit Profile → Profile Edit Screen
                  ├── Settings → Profile Settings Screen
                  ├── Verification → Verification Status Screen
                  ├── Wallet → Transaction History
                  └── Orders → Order History
```

### 2. Profile Edit Flow
```
Profile Screen → Edit Profile → Select Avatar → Save Changes → Profile Updated
```

### 3. Settings Flow
```
Profile Screen → Settings → Change Password → Verify Current → Set New → Success
                        ├── Notifications → Toggle Settings
                        ├── Privacy → Manage Settings
                        └── Delete Account → Confirm → Account Deleted
```

## Error Handling

### 1. Network Errors
- Connection timeout handling
- Retry mechanisms
- Offline state management

### 2. Validation Errors
- Real-time form validation
- User-friendly error messages
- Field-specific error display

### 3. Server Errors
- Graceful error handling
- Error message display
- Fallback UI states

## Performance Optimizations

### 1. Image Handling
- Image compression before upload
- Cached network images
- Lazy loading for avatars

### 2. Data Management
- Efficient API calls
- Local data caching
- Optimistic UI updates

### 3. UI Performance
- Smooth animations
- Efficient list rendering
- Memory management

## Testing

### 1. Unit Tests
- Service method testing
- Model validation testing
- Utility function testing

### 2. Integration Tests
- API endpoint testing
- Database operation testing
- Authentication flow testing

### 3. UI Tests
- Screen navigation testing
- Form validation testing
- User interaction testing

## Future Enhancements

### 1. Social Features
- Follow/unfollow users
- Profile sharing
- Social media integration

### 2. Advanced Settings
- Two-factor authentication
- Login history
- Device management

### 3. Profile Customization
- Profile themes
- Custom bio sections
- Profile badges

### 4. Analytics
- Profile view tracking
- Engagement analytics
- User behavior insights

## Dependencies

### Flutter Dependencies
```yaml
image_picker: ^1.0.4  # Avatar upload
dio: ^5.4.0          # HTTP client
shared_preferences: ^2.2.2  # Local storage
jwt_decoder: ^2.0.1  # JWT handling
```

### Backend Dependencies
```json
{
  "@nestjs/platform-express": "^10.0.0",
  "multer": "^1.4.5",
  "bcrypt": "^5.1.0"
}
```

## Configuration

### Environment Variables
```env
# File upload settings
MAX_FILE_SIZE=5242880  # 5MB
UPLOAD_PATH=./uploads

# Security settings
JWT_SECRET=your-jwt-secret
BCRYPT_ROUNDS=10
```

### App Configuration
```dart
// API configuration
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000';
  static const Duration timeout = Duration(seconds: 30);
}
```

This profile system provides a complete, secure, and user-friendly profile management experience that integrates seamlessly with the rest of the Social Live platform.
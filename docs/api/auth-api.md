# Authentication API

## Overview
JWT-based authentication system with refresh tokens, role-based access control, and comprehensive security features.

## Base URL
```
Production: https://api.sociallive.com
Staging: https://staging-api.sociallive.com
Development: http://localhost:3000
```

## Authentication Flow

### 1. User Registration
```http
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "username": "johndoe",
  "fullName": "John Doe"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "username": "johndoe",
      "fullName": "John Doe",
      "role": "USER",
      "isVerified": false,
      "createdAt": "2024-01-01T00:00:00Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIs...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
      "expiresIn": 3600
    }
  }
}
```

### 2. User Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "username": "johndoe",
      "fullName": "John Doe",
      "role": "USER",
      "isVerified": true,
      "lastLoginAt": "2024-01-01T00:00:00Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIs...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
      "expiresIn": 3600
    }
  }
}
```

### 3. Token Refresh
```http
POST /auth/refresh
Content-Type: application/json

{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIs...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
      "expiresIn": 3600
    },
    "version": 2
  }
}
```

### 4. Logout
```http
POST /auth/logout
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

## Protected Endpoints

### Authorization Header
All protected endpoints require the Authorization header:
```http
Authorization: Bearer <access_token>
```

### User Profile
```http
GET /auth/profile
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "username": "johndoe",
      "fullName": "John Doe",
      "role": "USER",
      "isVerified": true,
      "profilePicture": "https://cdn.example.com/profile.jpg",
      "bio": "Software developer",
      "followersCount": 150,
      "followingCount": 75,
      "postsCount": 42,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  }
}
```

### Update Profile
```http
PUT /auth/profile
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "fullName": "John Smith",
  "bio": "Full-stack developer",
  "profilePicture": "https://cdn.example.com/new-profile.jpg"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "fullName": "John Smith",
      "bio": "Full-stack developer",
      "profilePicture": "https://cdn.example.com/new-profile.jpg",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  }
}
```

## Password Management

### Change Password
```http
PUT /auth/password
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "currentPassword": "OldPass123!",
  "newPassword": "NewPass456!"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Password updated successfully"
}
```

### Forgot Password
```http
POST /auth/forgot-password
Content-Type: application/json

{
  "email": "user@example.com"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Password reset email sent"
}
```

### Reset Password
```http
POST /auth/reset-password
Content-Type: application/json

{
  "token": "reset_token_from_email",
  "newPassword": "NewPass789!"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Password reset successfully"
}
```

## Role-Based Access Control

### Roles
- **USER**: Standard user with basic permissions
- **CREATOR**: Content creator with additional permissions
- **ADMIN**: Administrator with full system access

### Role Permissions
```json
{
  "USER": [
    "read:posts",
    "create:posts",
    "update:own_posts",
    "delete:own_posts",
    "read:profile",
    "update:own_profile"
  ],
  "CREATOR": [
    "all_user_permissions",
    "create:live_streams",
    "manage:monetization",
    "access:analytics"
  ],
  "ADMIN": [
    "all_permissions",
    "manage:users",
    "manage:content",
    "access:admin_panel"
  ]
}
```

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "error": "VALIDATION_ERROR",
  "message": "Invalid input data",
  "details": [
    {
      "field": "email",
      "message": "Invalid email format"
    }
  ]
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "error": "UNAUTHORIZED",
  "message": "Invalid credentials"
}
```

### 403 Forbidden
```json
{
  "success": false,
  "error": "FORBIDDEN",
  "message": "Insufficient permissions"
}
```

### 429 Too Many Requests
```json
{
  "success": false,
  "error": "RATE_LIMIT_EXCEEDED",
  "message": "Too many requests",
  "retryAfter": 60
}
```

## Rate Limiting

### Authentication Endpoints
- **Login**: 5 requests per minute per IP
- **Register**: 3 requests per minute per IP
- **Password Reset**: 2 requests per hour per email

### Protected Endpoints
- **Profile Updates**: 10 requests per minute per user
- **General API**: 100 requests per minute per user

## Security Features

### Token Security
- **Access Token**: 1 hour expiration
- **Refresh Token**: 7 days expiration
- **Token Rotation**: New refresh token on each refresh
- **Token Revocation**: Immediate invalidation on logout

### Password Security
- **Minimum Length**: 8 characters
- **Complexity**: Must include uppercase, lowercase, number, special character
- **Hashing**: bcrypt with salt rounds 12
- **History**: Prevent reuse of last 5 passwords

### Account Security
- **Login Attempts**: Max 5 failed attempts before lockout
- **Lockout Duration**: 15 minutes
- **Session Management**: Single active session per device
- **Device Tracking**: Track login devices and locations

## SDK Examples

### JavaScript/TypeScript
```typescript
import { AuthClient } from '@sociallive/sdk';

const auth = new AuthClient({
  baseURL: 'https://api.sociallive.com',
  apiKey: 'your-api-key'
});

// Login
const { user, tokens } = await auth.login({
  email: 'user@example.com',
  password: 'password'
});

// Auto token refresh
auth.setTokens(tokens);
const profile = await auth.getProfile(); // Automatically handles token refresh
```

### Flutter/Dart
```dart
import 'package:social_live_sdk/auth.dart';

final auth = AuthService(
  baseUrl: 'https://api.sociallive.com',
  apiKey: 'your-api-key',
);

// Login
final result = await auth.login('user@example.com', 'password');
if (result.success) {
  final user = result.user;
  final tokens = result.tokens;
}

// Get profile
final profile = await auth.getProfile();
```

## Testing

### Test Accounts
```json
{
  "user": {
    "email": "testuser@example.com",
    "password": "TestPass123!"
  },
  "creator": {
    "email": "creator@example.com",
    "password": "CreatorPass123!"
  },
  "admin": {
    "email": "admin@example.com",
    "password": "AdminPass123!"
  }
}
```

### Postman Collection
Import the authentication collection: [Download Postman Collection](./assets/auth-api.postman_collection.json)
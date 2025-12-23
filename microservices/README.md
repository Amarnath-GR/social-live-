# Social Live Microservices Architecture

## Overview
Refactored the monolithic NestJS backend into a true microservices architecture with separate services for different business domains.

## Services

### API Gateway (Port 8080)
- **Purpose**: Single entry point for all client requests
- **Features**: Request routing, authentication middleware, load balancing
- **Routes**: 
  - `/auth/*` → Auth Service
  - `/social/*` → Social Service  
  - `/wallet/*` → Wallet Service
  - `/streaming/*` → Streaming Service
  - `/commerce/*` → Commerce Service

### Auth Service (Port 3001)
- **Purpose**: User authentication and authorization
- **Features**: JWT tokens, user registration/login, token verification
- **Endpoints**: `/register`, `/login`, `/refresh`, `/verify`, `/revoke`

### Social Service (Port 3002)
- **Purpose**: Posts, feed, comments, and social interactions
- **Features**: Content management, personalized feeds, engagement tracking
- **Endpoints**: `/posts`, `/feed`, `/comments`, `/likes`

### Wallet Service (Port 3003)
- **Purpose**: Digital wallet and transaction management
- **Features**: Balance management, deposits, withdrawals, transfers
- **Endpoints**: `/balance`, `/transactions`, `/deposit`, `/withdraw`, `/transfer`

### Streaming Service (Port 3004)
- **Purpose**: Live streaming and real-time communication
- **Features**: Stream management, WebSocket connections, viewer tracking
- **Endpoints**: `/start`, `/end`, `/live`, `/join`, `/leave`

### Commerce Service (Port 3005)
- **Purpose**: E-commerce and marketplace functionality
- **Features**: Product management, order processing, payment integration
- **Endpoints**: `/products`, `/orders`, `/payments`

## Inter-Service Communication

### HTTP REST API
- Services communicate via HTTP REST calls
- Shared `ServiceClient` class for consistent communication
- Service discovery via environment variables

### Message Patterns
```typescript
// Request/Response pattern
const response = await serviceClient.post('/endpoint', data);

// Service-to-service authentication
headers: { 'X-Service-Name': 'calling-service' }
```

## Quick Start

### Using Docker Compose
```bash
# Start all services
cd microservices
docker-compose up --build

# Or use the startup script
./start-microservices.sh  # Linux/Mac
start-microservices.bat   # Windows
```

### Manual Development
```bash
# Terminal 1 - API Gateway
cd api-gateway && npm install && npm run start:dev

# Terminal 2 - Auth Service  
cd auth-service && npm install && npm run start:dev

# Terminal 3 - Social Service
cd social-service && npm install && npm run start:dev

# Terminal 4 - Wallet Service
cd wallet-service && npm install && npm run start:dev

# Terminal 5 - Streaming Service
cd streaming-service && npm install && npm run start:dev

# Terminal 6 - Commerce Service
cd commerce-service && npm install && npm run start:dev
```

## Service URLs
- **API Gateway**: http://localhost:8080
- **Auth Service**: http://localhost:3001
- **Social Service**: http://localhost:3002
- **Wallet Service**: http://localhost:3003
- **Streaming Service**: http://localhost:3004
- **Commerce Service**: http://localhost:3005

## Client Integration

### Flutter App Updates
Update the API client to use the API Gateway:

```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8080';
  
  // Service endpoints via gateway
  static const String authEndpoint = '/auth';
  static const String socialEndpoint = '/social';
  static const String walletEndpoint = '/wallet';
  static const String streamingEndpoint = '/streaming';
  static const String commerceEndpoint = '/commerce';
}
```

### API Calls
```dart
// Authentication
final response = await apiClient.post('/auth/login', data: loginData);

// Posts
final posts = await apiClient.get('/social/posts');

// Wallet
final balance = await apiClient.get('/wallet/balance');

// Streaming
final streams = await apiClient.get('/streaming/live');

// Commerce
final products = await apiClient.get('/commerce/products');
```

## Architecture Benefits

### Scalability
- Independent scaling of services based on load
- Horizontal scaling with multiple instances
- Resource optimization per service

### Maintainability
- Clear separation of concerns
- Independent development and deployment
- Service-specific technology choices

### Reliability
- Fault isolation between services
- Circuit breaker patterns
- Graceful degradation

### Development
- Team autonomy per service
- Independent testing and deployment
- Technology diversity support

## Monitoring & Observability

### Health Checks
Each service exposes a `/health` endpoint:
```bash
curl http://localhost:3001/health  # Auth Service
curl http://localhost:3002/health  # Social Service
# ... etc
```

### Service Discovery
Services are discovered via environment variables:
```env
AUTH_SERVICE_URL=http://auth-service:3001
SOCIAL_SERVICE_URL=http://social-service:3002
WALLET_SERVICE_URL=http://wallet-service:3003
```

### Load Balancing
API Gateway handles load balancing and request routing to service instances.

## Security

### Authentication Flow
1. Client authenticates with Auth Service via API Gateway
2. Auth Service returns JWT token
3. API Gateway validates tokens for protected routes
4. Services trust requests from API Gateway

### Inter-Service Security
- Service-to-service authentication via headers
- Network isolation in production
- Encrypted communication between services

## Database Strategy

### Shared Database
Currently using shared PostgreSQL database for simplicity.

### Future: Database per Service
- Auth Service: User accounts and sessions
- Social Service: Posts, comments, feeds
- Wallet Service: Transactions and balances
- Streaming Service: Stream sessions and viewers
- Commerce Service: Products and orders

## Deployment

### Docker Compose (Development)
```bash
docker-compose up --build
```

### Kubernetes (Production)
Each service gets its own deployment, service, and ingress configuration.

### Environment Variables
```env
# API Gateway
PORT=8080
AUTH_SERVICE_URL=http://auth-service:3001
SOCIAL_SERVICE_URL=http://social-service:3002

# Individual Services
DATABASE_URL=postgresql://user:pass@postgres:5432/db
JWT_SECRET=your-secret
```

## Migration from Monolith

### Preserved Functionality
- ✅ User authentication and authorization
- ✅ Posts and feed management
- ✅ Wallet and transactions
- ✅ Live streaming features
- ✅ E-commerce functionality

### API Compatibility
- Routes updated to use service prefixes
- Response formats maintained
- Authentication flow preserved

### Database Schema
- Existing schema works with all services
- Future migration to service-specific databases planned
# Production Integration Plan

## Current State
- ✅ Production seed data exists (`production-seed.ts`)
- ✅ Production video service exists (`production-video.service.ts`)
- ✅ Production payment service exists (`production-payment.service.ts`)
- ❌ App still uses demo/mock services
- ❌ Cart functionality is stubbed
- ❌ Some services have mock data fallbacks

## Integration Tasks

### 1. Replace Mock Services with Production Services
- [ ] Update VideoModule to use ProductionVideoService
- [ ] Update PaymentModule to use ProductionPaymentService
- [ ] Remove demo/mock service imports

### 2. Implement Real Cart System
- [ ] Create Cart model in Prisma schema
- [ ] Implement cart CRUD operations
- [ ] Replace stubbed cart methods in MarketplaceService

### 3. Remove All Mock Data References
- [ ] Remove mock URLs from video service
- [ ] Remove demo endpoints
- [ ] Remove test data generators

### 4. Add Missing Database Fields
- [ ] Add stripeCustomerId to User model
- [ ] Add PaymentMethod model
- [ ] Add Payment model
- [ ] Add Refund model
- [ ] Add Cart and CartItem models

### 5. Environment Configuration
- [ ] Ensure all production env vars are documented
- [ ] Add validation for required env vars
- [ ] Create startup checks

### 6. Testing
- [ ] Test video upload flow
- [ ] Test payment processing
- [ ] Test cart operations
- [ ] Test order creation
- [ ] Test refund processing

## Execution Order
1. Update Prisma schema with missing models
2. Run migrations
3. Update services to use production implementations
4. Update controllers to use new services
5. Update app module imports
6. Run production seed
7. Test all flows

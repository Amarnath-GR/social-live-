# Quick Reference Guide

## Common Commands

### Setup & Installation

```bash
# Initial setup
setup-production.bat

# Verify setup
verify-production-setup.bat

# Install dependencies
cd social-live-mvp
npm install

# Generate Prisma client
npx prisma generate
```

### Database

```bash
# Run migrations
npx prisma migrate deploy

# Seed demo data
npm run seed

# Seed production data
npm run seed:production

# Open Prisma Studio
npx prisma studio

# Reset database (WARNING: Deletes all data)
npx prisma migrate reset
```

### Development

```bash
# Start backend (development)
cd social-live-mvp
npm run start:dev

# Start backend (production)
npm run build
npm run start:prod

# Start Flutter app
cd social-live-flutter
flutter run

# Start Flutter web
flutter run -d chrome
```

### Testing

```bash
# Run tests
npm test

# Run tests with coverage
npm run test:cov

# Run e2e tests
npm run test:e2e

# Test API endpoint
curl http://localhost:3000/api/videos/feed
```

### Production

```bash
# Build for production
npm run build

# Run production server
npm run start:prod

# Build Flutter app
flutter build apk --release
flutter build ios --release
flutter build web --release
```

---

## Environment Variables

### Required

```env
DATABASE_URL="postgresql://user:pass@host:5432/db"
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
STRIPE_SECRET_KEY=sk_live_xxxxx
JWT_SECRET=your-secret-key
```

### Optional

```env
REDIS_URL=redis://localhost:6379
SENTRY_DSN=https://xxxxx@sentry.io/xxxxx
SENDGRID_API_KEY=SG.xxxxx
```

---

## API Endpoints

### Authentication

```bash
# Register
POST /api/auth/register
{
  "email": "user@example.com",
  "username": "username",
  "password": "Password123!"
}

# Login
POST /api/auth/login
{
  "email": "user@example.com",
  "password": "Password123!"
}
```

### Videos

```bash
# Get feed
GET /api/videos/feed?page=1&limit=20
Authorization: Bearer <token>

# Upload video
POST /api/videos/upload
Authorization: Bearer <token>
Content-Type: multipart/form-data

# Like video
POST /api/videos/:id/like
Authorization: Bearer <token>

# Comment on video
POST /api/videos/:id/comment
Authorization: Bearer <token>
{
  "content": "Great video!"
}
```

### Marketplace

```bash
# Get products
GET /api/marketplace/products?page=1&limit=20

# Get product details
GET /api/marketplace/products/:id

# Purchase product
POST /api/marketplace/purchase
Authorization: Bearer <token>
{
  "productId": "xxx",
  "quantity": 1
}
```

### Wallet

```bash
# Get balance
GET /api/wallet/balance
Authorization: Bearer <token>

# Add funds
POST /api/wallet/add-funds
Authorization: Bearer <token>
{
  "amount": 5000,
  "paymentMethodId": "pm_xxxxx"
}

# Get transactions
GET /api/wallet/transactions?page=1&limit=20
Authorization: Bearer <token>
```

---

## Troubleshooting

### Database Connection Error

```bash
# Check DATABASE_URL in .env
# Make sure PostgreSQL is running
# Test connection:
npx prisma db pull
```

### Prisma Client Error

```bash
# Regenerate Prisma client
npx prisma generate

# If still failing, delete and regenerate
rm -rf node_modules/.prisma
npx prisma generate
```

### Port Already in Use

```bash
# Find process using port 3000
netstat -ano | findstr :3000

# Kill process (Windows)
taskkill /PID <PID> /F

# Or change port in .env
PORT=3001
```

### AWS S3 Upload Error

```bash
# Check AWS credentials in .env
# Verify S3 bucket exists
# Check bucket permissions
# Test with AWS CLI:
aws s3 ls s3://your-bucket-name
```

### Stripe Payment Error

```bash
# Check Stripe keys in .env
# Verify keys are for correct environment (test/live)
# Check Stripe dashboard for errors
# Test with Stripe CLI:
stripe listen --forward-to localhost:3000/api/webhooks/stripe
```

---

## File Locations

### Configuration

- `.env` - Environment variables
- `prisma/schema.prisma` - Database schema
- `package.json` - Dependencies and scripts

### Source Code

- `src/main.ts` - Application entry point
- `src/app.module.ts` - Main module
- `src/seed/production-seed.ts` - Production data
- `src/video/production-video.service.ts` - Video service
- `src/payments/production-payment.service.ts` - Payment service

### Documentation

- `PRODUCTION_READY_SUMMARY.md` - Overview
- `PRODUCTION_DEPLOYMENT_GUIDE.md` - Deployment
- `PRODUCTION_CHECKLIST.md` - Pre-launch checklist
- `QUICK_REFERENCE.md` - This file

---

## Default Credentials

### Demo Users (after seeding)

```
Email: sarah.johnson@example.com
Password: SecurePass123!

Email: mike.chen@example.com
Password: SecurePass123!

Email: emma.davis@example.com
Password: SecurePass123!
```

### Admin User

```
Email: admin@demo.com
Password: Demo123!
```

---

## Useful Links

### Documentation

- [NestJS Docs](https://docs.nestjs.com/)
- [Prisma Docs](https://www.prisma.io/docs/)
- [Flutter Docs](https://flutter.dev/docs)
- [Stripe Docs](https://stripe.com/docs)
- [AWS S3 Docs](https://docs.aws.amazon.com/s3/)

### Tools

- [Prisma Studio](http://localhost:5555) - Database GUI
- [Stripe Dashboard](https://dashboard.stripe.com/) - Payment management
- [AWS Console](https://console.aws.amazon.com/) - AWS services
- [Sentry](https://sentry.io/) - Error tracking

---

## Production Checklist

### Before Deployment

- [ ] Configure all environment variables
- [ ] Set up AWS S3 and CloudFront
- [ ] Configure Stripe account
- [ ] Set up PostgreSQL database
- [ ] Run production seed data
- [ ] Test all critical flows
- [ ] Set up monitoring and alerts

### After Deployment

- [ ] Monitor error rates
- [ ] Check performance metrics
- [ ] Verify payment processing
- [ ] Test video uploads
- [ ] Check user registrations
- [ ] Monitor server resources

---

## Support

### Getting Help

1. Check documentation files
2. Review error logs
3. Check GitHub issues
4. Contact support team

### Reporting Issues

Include:
- Error message
- Steps to reproduce
- Environment details
- Logs (if applicable)

---

## Quick Tips

### Performance

- Use Redis for caching
- Enable CDN for videos
- Optimize database queries
- Use connection pooling

### Security

- Always use HTTPS
- Keep dependencies updated
- Use strong JWT secrets
- Enable rate limiting
- Validate all inputs

### Monitoring

- Set up error tracking (Sentry)
- Monitor API response times
- Track user engagement
- Monitor server resources
- Set up alerts for critical issues

---

**Last Updated:** December 24, 2024

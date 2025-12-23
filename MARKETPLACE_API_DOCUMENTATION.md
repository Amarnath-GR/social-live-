# Marketplace Backend API Documentation

## Overview
Complete marketplace backend implementation with product catalog, creator-owned products, pricing/inventory management, secure CRUD APIs, and product discovery endpoints.

## Database Schema

### Product Model
```prisma
model Product {
  id          String   @id @default(cuid())
  name        String
  description String
  price       Int      // Price in coins
  imageUrl    String?
  category    String
  tags        String?  // JSON array of tags
  inventory   Int      @default(0)
  isActive    Boolean  @default(true)
  creatorId   String
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  creator    User        @relation(fields: [creatorId], references: [id], onDelete: Cascade)
  orderItems OrderItem[]

  @@index([creatorId])
  @@index([category])
  @@index([isActive, createdAt])
}
```

### Order & OrderItem Models
```prisma
model Order {
  id        String      @id @default(cuid())
  userId    String
  total     Int         // Total in coins
  status    String      @default("PENDING")
  createdAt DateTime    @default(now())
  updatedAt DateTime    @updatedAt

  user       User        @relation(fields: [userId], references: [id], onDelete: Cascade)
  orderItems OrderItem[]
}

model OrderItem {
  id        String @id @default(cuid())
  orderId   String
  productId String
  quantity  Int
  price     Int    // Price at time of purchase

  order   Order   @relation(fields: [orderId], references: [id], onDelete: Cascade)
  product Product @relation(fields: [productId], references: [id], onDelete: Cascade)
}
```

## API Endpoints

### Product Management

#### Create Product
- **POST** `/api/v1/marketplace/products`
- **Auth**: Required (JWT)
- **Body**:
```json
{
  "name": "Product Name",
  "description": "Product description",
  "price": 50,
  "imageUrl": "https://example.com/image.jpg",
  "category": "Digital Assets",
  "tags": "tag1,tag2,tag3",
  "inventory": 100
}
```

#### Get Products (Catalog)
- **GET** `/api/v1/marketplace/products`
- **Query Parameters**:
  - `page`: Page number (default: 1)
  - `limit`: Items per page (default: 20)
  - `category`: Filter by category
  - `search`: Search in name/description
  - `creatorId`: Filter by creator
  - `sortBy`: Sort field (default: createdAt)
  - `sortOrder`: asc/desc (default: desc)

#### Get Product by ID
- **GET** `/api/v1/marketplace/products/:id`

#### Update Product
- **PUT** `/api/v1/marketplace/products/:id`
- **Auth**: Required (Creator only)

#### Delete Product
- **DELETE** `/api/v1/marketplace/products/:id`
- **Auth**: Required (Creator only)

### Product Discovery

#### Search Products
- **GET** `/api/v1/marketplace/search`
- **Query**: Same as Get Products

#### Featured Products
- **GET** `/api/v1/marketplace/featured`
- **Query**: `limit` (default: 10)

#### Categories
- **GET** `/api/v1/marketplace/categories`
- **Response**:
```json
{
  "success": true,
  "data": [
    {
      "name": "Digital Assets",
      "count": 15
    }
  ]
}
```

### Order Management

#### Create Order
- **POST** `/api/v1/marketplace/orders`
- **Auth**: Required
- **Body**:
```json
{
  "items": [
    {
      "productId": "product_id",
      "quantity": 2
    }
  ]
}
```

#### Get User Orders
- **GET** `/api/v1/marketplace/orders`
- **Auth**: Required
- **Query**: `page`, `limit`

### Creator Management

#### Get Creator Products
- **GET** `/api/v1/marketplace/creator/products`
- **Auth**: Required
- **Query**: `page`, `limit`

## Security Features

### Authentication & Authorization
- JWT-based authentication for all protected endpoints
- Creator ownership validation for product modifications
- User-specific order access control

### Input Validation
- Comprehensive DTO validation using class-validator
- Price and inventory constraints
- String length limits for security

### Transaction Safety
- Database transactions for order creation
- Inventory management with atomic updates
- Wallet balance validation and deduction

## Business Logic

### Inventory Management
- Real-time inventory tracking
- Automatic inventory deduction on purchase
- Insufficient inventory validation

### Pricing System
- Coin-based pricing system
- Price preservation in order history
- Dynamic pricing support

### Wallet Integration
- Automatic wallet balance validation
- Transaction recording for purchases
- Insufficient funds handling

## Sample Data Categories
1. **Digital Assets** - Overlays, emotes, graphics
2. **Education** - Guides, tutorials, courses
3. **Services** - Editing, setup, consultation
4. **Audio** - Music packs, sound effects
5. **Graphics** - Thumbnails, banners, logos
6. **Tools** - Software, plugins, utilities
7. **Templates** - Stream layouts, designs
8. **Merchandise** - Physical products, branded items

## Error Handling
- Comprehensive error responses
- Business logic validation
- Resource not found handling
- Permission denied responses

## Performance Optimizations
- Database indexing on key fields
- Pagination for large datasets
- Efficient query patterns
- Minimal data transfer

## Integration Points
- User authentication system
- Wallet/payment system
- Media upload service
- Real-time notifications (future)

The marketplace backend is production-ready with all requested features implemented!
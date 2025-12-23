const express = require('express');
const os = require('os');

const app = express();
const PORT = 2307;

// Enable CORS manually
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
});

app.use(express.json());

// Health check endpoints (both formats)
app.get('/api/v1/health', (req, res) => {
  res.json({
    success: true,
    message: 'Backend server is running',
    timestamp: new Date().toISOString(),
    status: 'ok',
    data: {
      server: 'Quick Backend',
      version: '1.0.0'
    }
  });
});

app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Backend server is running',
    timestamp: new Date().toISOString(),
    status: 'ok',
    data: {
      server: 'Quick Backend',
      version: '1.0.0'
    }
  });
});

// Auth endpoints
app.post('/api/v1/auth/login', (req, res) => {
  const { email, password } = req.body;
  
  // Demo accounts
  const demoAccounts = {
    'admin@demo.com': { password: 'Demo123!', role: 'admin', id: 1 },
    'john@demo.com': { password: 'Demo123!', role: 'user', id: 2 }
  };
  
  const user = demoAccounts[email];
  if (user && user.password === password) {
    res.json({
      success: true,
      token: 'demo-jwt-token-' + user.id,
      user: {
        id: user.id,
        email: email,
        role: user.role
      }
    });
  } else {
    res.status(401).json({
      success: false,
      message: 'Invalid credentials'
    });
  }
});

// Profile endpoints
app.get('/api/v1/profile', (req, res) => {
  res.json({
    success: true,
    data: {
      id: 1,
      email: 'john@demo.com',
      name: 'John Demo',
      avatar: null,
      phone: '+1234567890',
      createdAt: '2024-01-01T00:00:00Z'
    }
  });
});

// Wallet endpoints
app.get('/api/v1/wallet', (req, res) => {
  res.json({
    success: true,
    data: {
      balance: 1000.00,
      currency: 'USD'
    }
  });
});

app.get('/api/v1/wallet/balance', (req, res) => {
  res.json({
    success: true,
    balance: 1000.00,
    currency: 'USD'
  });
});

// Transaction history
app.get('/api/v1/wallet/transactions', (req, res) => {
  res.json({
    success: true,
    data: [
      {
        id: 1,
        type: 'CREDIT',
        amount: 500.00,
        description: 'Initial deposit',
        createdAt: '2024-01-15T10:30:00Z',
        status: 'POSTED'
      },
      {
        id: 2,
        type: 'DEBIT',
        amount: 50.00,
        description: 'Stream tip',
        createdAt: '2024-01-14T15:45:00Z',
        status: 'POSTED'
      },
      {
        id: 3,
        type: 'CREDIT',
        amount: 100.00,
        description: 'Gift received',
        createdAt: '2024-01-13T12:20:00Z',
        status: 'POSTED'
      }
    ]
  });
});

// Order history
app.get('/api/v1/orders', (req, res) => {
  res.json({
    success: true,
    orders: [
      {
        id: 'ORD001',
        type: 'gift',
        total: 25.00,
        status: 'delivered',
        createdAt: '2024-01-13T20:15:00Z',
        orderItems: [
          {
            id: 1,
            productName: 'Heart Gift',
            quantity: 1,
            price: 25.00
          }
        ]
      },
      {
        id: 'ORD002',
        type: 'subscription',
        total: 9.99,
        status: 'confirmed',
        createdAt: '2024-01-01T12:00:00Z',
        orderItems: [
          {
            id: 2,
            productName: 'Monthly Subscription',
            quantity: 1,
            price: 9.99
          }
        ]
      }
    ]
  });
});

// Comments endpoints
app.get('/api/v1/posts/:postId/comments', (req, res) => {
  res.json({
    success: true,
    data: [
      {
        id: 1,
        postId: req.params.postId,
        userId: 1,
        user: { name: 'John Doe', avatar: null },
        content: 'Great post!',
        createdAt: '2024-01-15T10:30:00Z'
      }
    ]
  });
});

app.post('/api/v1/posts/:postId/comments', (req, res) => {
  const { content } = req.body;
  res.json({
    success: true,
    data: {
      id: Date.now(),
      postId: req.params.postId,
      userId: 1,
      user: { name: 'John Demo', avatar: null },
      content: content,
      createdAt: new Date().toISOString()
    }
  });
});

// Stream endpoints
app.get('/api/v1/streams/active', (req, res) => {
  res.json({
    success: true,
    streams: [
      {
        id: 1,
        title: 'Demo Live Stream',
        streamer: 'Demo User',
        viewers: 42,
        isLive: true
      }
    ]
  });
});

// Marketplace endpoints
app.get('/api/v1/marketplace/products', (req, res) => {
  const { category, search, sortBy } = req.query;
  
  let products = [
    {
      id: '1',
      name: 'Premium Stream Overlay Pack',
      description: 'Professional animated overlay collection with alerts, frames, and transitions.',
      price: 75,
      category: 'Digital Assets',
      inventory: 50,
      creator: { name: 'John Doe', username: 'john_doe' },
    },
    {
      id: '2',
      name: 'Custom Emote Bundle',
      description: 'Set of 15 custom emotes designed for your community.',
      price: 45,
      category: 'Digital Assets',
      inventory: 30,
      creator: { name: 'Jane Smith', username: 'jane_smith' },
    },
    {
      id: '3',
      name: 'Complete Streaming Setup Guide',
      description: 'Comprehensive guide covering equipment, software, and best practices.',
      price: 35,
      category: 'Education',
      inventory: 100,
      creator: { name: 'Mike Wilson', username: 'mike_wilson' },
    },
    {
      id: '4',
      name: 'Video Editing Service',
      description: 'Professional video editing for highlights and promotional content.',
      price: 95,
      category: 'Services',
      inventory: 15,
      creator: { name: 'Sarah Jones', username: 'sarah_jones' },
    },
    {
      id: '5',
      name: 'Royalty-Free Music Pack',
      description: 'Collection of 50 high-quality background tracks perfect for streaming.',
      price: 55,
      category: 'Audio',
      inventory: 75,
      creator: { name: 'Demo Admin', username: 'admin' },
    },
  ];
  
  // Filter by category
  if (category) {
    products = products.filter(p => p.category === category);
  }
  
  // Filter by search
  if (search) {
    products = products.filter(p => 
      p.name.toLowerCase().includes(search.toLowerCase()) ||
      p.description.toLowerCase().includes(search.toLowerCase())
    );
  }
  
  // Sort products
  if (sortBy) {
    switch (sortBy) {
      case 'price_low':
        products.sort((a, b) => a.price - b.price);
        break;
      case 'price_high':
        products.sort((a, b) => b.price - a.price);
        break;
      case 'oldest':
        products.reverse();
        break;
      case 'newest':
      default:
        // Keep original order
        break;
    }
  }
  
  res.json({
    success: true,
    data: products
  });
});

app.get('/api/v1/marketplace/categories', (req, res) => {
  res.json({
    success: true,
    data: [
      { name: 'Digital Assets', count: 2 },
      { name: 'Education', count: 1 },
      { name: 'Services', count: 1 },
      { name: 'Audio', count: 1 },
    ]
  });
});

app.get('/api/v1/marketplace/products/:id', (req, res) => {
  const { id } = req.params;
  const products = [
    {
      id: '1',
      name: 'Premium Stream Overlay Pack',
      description: 'Professional animated overlay collection with alerts, frames, and transitions.',
      price: 75,
      category: 'Digital Assets',
      inventory: 50,
      creator: { name: 'John Doe', username: 'john_doe' },
    },
    {
      id: '2',
      name: 'Custom Emote Bundle',
      description: 'Set of 15 custom emotes designed for your community.',
      price: 45,
      category: 'Digital Assets',
      inventory: 30,
      creator: { name: 'Jane Smith', username: 'jane_smith' },
    },
    {
      id: '3',
      name: 'Complete Streaming Setup Guide',
      description: 'Comprehensive guide covering equipment, software, and best practices.',
      price: 35,
      category: 'Education',
      inventory: 100,
      creator: { name: 'Mike Wilson', username: 'mike_wilson' },
    },
    {
      id: '4',
      name: 'Video Editing Service',
      description: 'Professional video editing for highlights and promotional content.',
      price: 95,
      category: 'Services',
      inventory: 15,
      creator: { name: 'Sarah Jones', username: 'sarah_jones' },
    },
    {
      id: '5',
      name: 'Royalty-Free Music Pack',
      description: 'Collection of 50 high-quality background tracks perfect for streaming.',
      price: 55,
      category: 'Audio',
      inventory: 75,
      creator: { name: 'Demo Admin', username: 'admin' },
    },
  ];
  
  const product = products.find(p => p.id === id);
  if (product) {
    res.json({
      success: true,
      data: product
    });
  } else {
    res.status(404).json({
      success: false,
      message: 'Product not found'
    });
  }
});

// Get local IP address
function getLocalIP() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const interface of interfaces[name]) {
      if (interface.family === 'IPv4' && !interface.internal) {
        return interface.address;
      }
    }
  }
  return 'localhost';
}

// Start server
app.listen(PORT, '0.0.0.0', () => {
  const localIP = getLocalIP();
  console.log(`🚀 Quick Backend Server running on port ${PORT}`);
  console.log(`📡 Local access: http://localhost:${PORT}/api/v1`);
  console.log(`📱 Mobile/Emulator access: http://${localIP}:${PORT}/api/v1`);
  console.log(`🌐 Network access: http://0.0.0.0:${PORT}/api/v1`);
  console.log(`✅ Health check: http://localhost:${PORT}/api/v1/health`);
  console.log(`\n📋 Demo accounts:`);
  console.log(`- admin@demo.com / Demo123!`);
  console.log(`- john@demo.com / Demo123!`);
  console.log(`\n🔧 Flutter app should connect to: http://${localIP}:${PORT}/api/v1`);
});
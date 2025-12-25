const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/api/v1/health', (req, res) => {
  res.json({ success: true, message: 'Backend is running', timestamp: new Date().toISOString() });
});

// Auth endpoints
app.post('/api/v1/auth/login', (req, res) => {
  const { email, password } = req.body;
  
  if (email === 'admin@demo.com' && password === 'Demo123!') {
    res.json({
      success: true,
      data: {
        tokens: {
          accessToken: 'mock-access-token-admin',
          refreshToken: 'mock-refresh-token-admin'
        },
        user: {
          id: '1',
          email: 'admin@demo.com',
          name: 'Admin User',
          role: 'admin'
        }
      }
    });
  } else if (email === 'john@demo.com' && password === 'Demo123!') {
    res.json({
      success: true,
      data: {
        tokens: {
          accessToken: 'mock-access-token-user',
          refreshToken: 'mock-refresh-token-user'
        },
        user: {
          id: '2',
          email: 'john@demo.com',
          name: 'John Doe',
          role: 'user'
        }
      }
    });
  } else {
    res.status(401).json({
      success: false,
      message: 'Invalid credentials'
    });
  }
});

// Mock posts endpoint
app.get('/api/v1/posts', (req, res) => {
  res.json([
    { id: 1, title: 'Welcome to Social Live', content: 'This is a demo post' },
    { id: 2, title: 'Live Streaming', content: 'Start your live stream now' }
  ]);
});

// Wallet balance endpoint
app.get('/api/v1/wallet/balance/:accountId', (req, res) => {
  res.json({
    success: true,
    balance: 1000,
    currency: 'coins'
  });
});

app.listen(PORT, () => {
  console.log(`Mock backend server running on http://localhost:${PORT}`);
  console.log('Available endpoints:');
  console.log('- GET /api/v1/health');
  console.log('- POST /api/v1/auth/login');
  console.log('- GET /api/v1/posts');
  console.log('- GET /api/v1/wallet/balance/:accountId');
});
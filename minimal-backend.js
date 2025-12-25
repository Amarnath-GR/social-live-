const express = require('express');
const cors = require('cors');

const app = express();
const PORT = 3000;

// Enable CORS for all origins
app.use(cors({
  origin: true,
  credentials: true
}));

app.use(express.json());

// Health check endpoint
app.get('/api/v1/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Backend is running',
    timestamp: new Date().toISOString(),
    port: PORT
  });
});

// Root health check for compatibility
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Backend is running',
    timestamp: new Date().toISOString(),
    port: PORT
  });
});

// Test endpoint
app.get('/api/v1/test', (req, res) => {
  res.json({
    message: 'Backend server is working!',
    endpoints: [
      'GET /api/v1/health',
      'GET /api/v1/test'
    ]
  });
});

// Basic auth endpoints for Flutter app
app.post('/api/v1/auth/login', (req, res) => {
  res.json({
    success: true,
    token: 'mock-jwt-token',
    user: { id: 1, username: 'testuser' }
  });
});

app.post('/api/v1/auth/register', (req, res) => {
  res.json({
    success: true,
    message: 'User registered successfully'
  });
});

// Posts endpoint
app.get('/api/v1/posts', (req, res) => {
  res.json({
    posts: [
      { id: 1, title: 'Test Post', content: 'This is a test post' }
    ]
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Minimal backend server running on http://localhost:${PORT}`);
  console.log(`📡 API available at http://localhost:${PORT}/api/v1`);
  console.log(`✅ Test the connection: http://localhost:${PORT}/api/v1/health`);
});
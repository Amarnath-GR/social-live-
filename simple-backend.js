const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// Health check
app.get('/api/v1/health', (req, res) => {
  res.json({ success: true, status: 'ok' });
});

// Mock endpoints
app.get('/api/v1/users/me', (req, res) => {
  res.json({
    success: true,
    data: {
      id: '1',
      username: 'testuser',
      name: 'Test User',
      email: 'test@example.com',
      avatar: null,
      bio: 'Test bio',
      followersCount: 100,
      followingCount: 50,
      stats: { posts: 10, likes: 200, comments: 30 }
    }
  });
});

app.get('/api/v1/wallet/balance', (req, res) => {
  res.json({ success: true, data: { balance: 1000 } });
});

app.get('/api/v1/wallet/transactions', (req, res) => {
  res.json({ success: true, data: [] });
});

app.get('/api/v1/posts/user/:userId', (req, res) => {
  res.json({ success: true, posts: [] });
});

app.get('/api/v1/comments/post/:postId', (req, res) => {
  res.json({ success: true, comments: [] });
});

app.post('/api/v1/comments', (req, res) => {
  res.json({ success: true, data: { id: '1', content: req.body.content } });
});

app.get('/api/v1/marketplace/orders/user', (req, res) => {
  res.json({ success: true, orders: [] });
});

const PORT = 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Backend server running on http://localhost:${PORT}`);
  console.log(`Backend server running on http://192.168.1.6:${PORT}`);
});